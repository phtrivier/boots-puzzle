# Boots Puzzle - gui.rb
#
# Gosu application to play the puzzle
#
# Copyright (C) 2008 Pierre-Henri Trivier
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA

begin
  # In case you use Gosu via RubyGems.
  require 'rubygems'
rescue LoadError
  # In case you don't.
end

require 'gosu'

module ZOrder
  Background, Stars, Player, UI = *0..3
end

require 'puzzle'
require 'plugins'
require 'action'
require 'adventure'

require 'game_modes'
require 'text_fitter'
require 'text_cutter'
# --------------------------------------------
# Game UI

class GameWindow < Gosu::Window

  attr_reader :puzzle, :font

  White = Gosu::Color.new(0xffffffff)
  # Maximum dimension of puzzles
  H = 10
  W = 16

  def initialize(props)
    super(640, 480, false)

    @prefix = props[:prefix]
    if (@prefix == nil)
      @prefix = "."
    end

    # Init the plugin system
    Plugins.init("#{@prefix}/plugins")
    Plugins.read_manifests

    @font = Gosu::Font.new(self, Gosu::default_font_name, 20)

    @fitter = TextFitter.new(@font, 600)
    @message_cutter = TextCutter.new(@fitter)
    @text_h = @font.height

    @quote_text_fitter = TextFitter.new(@font, 300)
    @quote_text_cutter = TextCutter.new(@quote_text_fitter)

    @quote_author_fitter = TextFitter.new(@font, 200)
    @quote_author_cutter = TextCutter.new(@quote_author_fitter)

    @last_message = nil

    @adventure = nil

    adventure_name = props[:adventure_name]

    @adventure = Adventure.new
    begin
      @adventure.load!(File.open("#{@prefix}/adventures/#{adventure_name}/adventure.yml"))
    rescue Exception => e
      puts "Unable to open adventure #{adventure_name} : #{e}"
      exit
    end
    @adventure.load_plugins!

    if (@adventure.has_next_level?)

      if (props[:level_name]!=nil and @adventure.has_level_named?(props[:level_name]))
        @adventure.go_to_level_named!(props[:level_name])
        @adventure.load_current_level!
      else
        @adventure.load_next_level!
      end

      @puzzle = @adventure.current_level.puzzle
    else
      puts "This adventure has nothing to play !!"
      exit
    end

    # Init the puzzle
    init_puzzle

    # No hint at startup
    @hint = false

    init_hints_images

    init_adventure_images

    @images = { }

    @player_img = Gosu::Image.new(self, to_image_path(@puzzle.player.src), false)

    @game_mode = SplashScreenMode.new(self)

    self.caption = "Boots Puzzle v#{BP_VERSION} -- #{@adventure.name}"

  end

  def init_puzzle
    # Listen to messages
    @puzzle.add_listener self
    @puzzle.enters_player!
    @last_message = "Entering level : #{@adventure.current_level.puzzle_name}\nPress 'h' for help."
  end

  def init_adventure_images
    @bg_image = load_adventure_image("background.png")
    @splash_screen = load_adventure_image("splash_screen.png")
    @end_screen = load_adventure_image("end_screen.png")
  end

  # Initialize a map with the images to
  # display for hints
  def init_hints_images
    @hints_images = { }
    Directions.each do |dir|
      @hints_images[dir] = load_hint_image(dir)
    end
  end

  # Load the image for an hint
  def load_hint_image(dir)
    load_gui_image("hint_#{dir}.png")
  end

  def reload_current_puzzle!
    # TODO : FACTOR WITH WHAT IS DONE THE FIRST TIME?
    @adventure.load_current_level!
    @puzzle = @adventure.current_level.puzzle
    init_puzzle
  end

  # Loads an image from the 'gui/img' folder
  # filename : name of the image file (eg background.png)
  def load_gui_image(filename)
    Gosu::Image.new(self, "#{@prefix}/gui/img/#{filename}")
  end

  def load_adventure_image(pic_filename)
    default_path = "#{@prefix}/gui/img/#{pic_filename}"
    adventure_image_path = "#{@prefix}/adventures/#{@adventure.name}/img/#{pic_filename}"
    if (File.exists?(adventure_image_path))
      path = adventure_image_path
    else
      path = default_path
    end
    Gosu::Image.new(self, path, false)
  end

  def update
    @game_mode.update
    # Move
    #   @actions.each do |name, action|
    #  action.evaluate
    #end
  end

  def check_level_finished
    # Change level if required
    if (@adventure.current_level.finished?)

      if (@adventure.has_next_level?)
        @adventure.load_next_level!
        @puzzle = @adventure.current_level.puzzle
        init_puzzle
        enter_game!
      else
        @game_mode = EndScreenMode.new(self)
      end
    end
  end

  def quit
    puts "Thanks for playing !"
    exit
  end

  def draw
    # draw_puzzle
    @game_mode.draw
  end

  def draw_puzzle

    @x0 = 20
    @y0 = 20
    @s = 32

    draw_background

    @puzzle.each_cell do |i,j,c|
      draw_cell(i,j,c)

      b = @puzzle.boot_at(i,j)
      if (b!=nil)
        draw_boot(i,j,c,b)
      end

    end

    draw_player

    draw_ui

#    puts "Should draw hint ? #{@hint}"
    if (@hint)
      draw_hint
    end

  end

  # Draws an image of an arrow on each cell that is walkable and reachable using the current boots
  def draw_hint
    h = @puzzle.player.current_boots.hints(@puzzle)
    h.each do |dir, pos|
      i,j = pos
      draw_on_cell(@hints_images[dir], i, j)
    end
  end

  def draw_background
    @bg_image.draw(0,0,ZOrder::UI)
    # Draw a rectangle around the game area
    draw_rectangle(@x0-5, @y0-5, @x0 + W*@s + 5, @y0 + H*@s + 5, White)
  end

  def to_screen_coords(i,j)
    x = @x0 + j * @s
    y = @y0 + i * @s
    [x,y]
  end

  def draw_on_cell(img, i,j)
    x,y = to_screen_coords(i,j)
    img.draw(x,y,ZOrder::UI)
  end

  def draw_player
    # TODO Reduce
    i,j = @puzzle.player.pos
    x,y = to_screen_coords(i,j)
    @player_img.draw(x,y, ZOrder::UI)
  end

  def draw_cell(i,j,c)
    # TODO Reduce
    x,y = to_screen_coords(i,j)
    i = get_image(c)
    i.draw(x,y, ZOrder::UI)
  end

  def draw_boot(i,j,c,b)
    # TODO Reduce
    x,y = to_screen_coords(i,j)
    img = image(b.src)
    img.draw(x,y, ZOrder::UI)
  end

  def draw_ui
    draw_boots_ui
    draw_message_ui
    # draw_keys_ui
  end

  # Draw the part of the UI where the current boot is displayed
  def draw_boots_ui
    @boots_ui_x0 = 580
    @boots_ui_y0 = 25
    interval = 25

    x = @boots_ui_x0
    y = @boots_ui_y0

    # Draw a nice line around everything
    draw_rectangle(x-10, y-10, x + @s + 10, y + 5 + (@s*3) + (interval*2) + 10, White)

    # Draw each boots, surrounding the selected one
    @puzzle.player.each_boots do |boot, selected|

      boot_image = image(boot.src)
      boot_image.draw(x,y, ZOrder::UI)

      if (selected)

        # Draw a quad around the selected one ...
        draw_rectangle(x-5, y-5, x+@s+5, y+@s+5, Gosu::Color.new(0xffff0000))

      end

      y = y + @s + interval

    end

  end

  def draw_message_ui
    # TODO : Compute the actual positions of where we should start writing text
    # TODO : hide the zone (in black) and write messages when they come in !
    y0 = @y0 + @s*H + 5 + 10
    x1 = 620
    height = 110

    draw_rectangle @x0 - 5, y0, x1, y0 + height, White

    # Print the text of last message
    if (@last_message != nil)
      safe_draw_text(@x0, y0 + 5, @message_cutter, @last_message)
    end
  end

  def safe_draw_text(x,y,cutter,msg)
    lines = cutter.cut_text(msg)
    if (lines.empty?)
      # Text could not be reduced to fit.
      # Mention it (with a !), and display the
      # text on the whole line -- it might overflow !
      lines = ["!" + msg]
    end
    lines.each do |line|
      @font.draw(line, x, y, ZOrder::UI, 1.0,1.0, White)
      y = y + @text_h + 2
    end
  end

  # Handlers for the messages
  def handle_message(ops)
    @last_message = ops[:msg]
  end

  # Draw a rectangle
  # Point order is as follow :
  # O x1,y1 --- O #x2,y1
  # |           |
  # O x1,y2 --- O x2,y2
  def draw_rectangle(x1,y1,x2,y2,color)
    draw_line(x1,y1,color,x2,y1,color,ZOrder::UI)
    draw_line(x2,y1,color,x2,y2,color,ZOrder::UI)
    draw_line(x2,y2,color,x1,y2,color,ZOrder::UI)
    draw_line(x1,y2,color,x1,y1,color,ZOrder::UI)
  end

  # Load an image from its source ... potentially leaky
  def image(src)
    Gosu::Image.new(self, to_image_path(src), false)
  end

  # Locate the image (it must be available globally ?)
  def to_image_path(src)
    "#{@prefix}/plugins/#{src}"
  end

  def get_image(cell)
    if (not @images.has_key?(cell.src))
      @images[cell.src] = image(cell.src)
    end
    res = @images[cell.src]

    res
  end

  def button_down(id)
    if id == Gosu::Button::KbEscape then
      close
    end
  end

  def enter_game!
    if (@puzzle.quote != nil)
      @game_mode = QuoteMode.new(self)
    else
      @game_mode = InPlayGameMode.new(self)
    end
  end

  def leave_quote!
    @game_mode = InPlayGameMode.new(self)
  end

  def draw_splash_screen
    @splash_screen.draw(0,0,ZOrder::UI)
  end

  def draw_end_screen
    @end_screen.draw(0,0,ZOrder::UI)
  end

  def draw_quote
    @bg_image.draw(0,0,ZOrder::UI)
    safe_draw_text(50,100, @quote_text_cutter, "'#{@puzzle.quote.text}'")
    if (@puzzle.quote.author != nil)
      safe_draw_text(450, 400, @quote_author_cutter , @puzzle.quote.author)
    end
    safe_draw_text(50, 450, @message_cutter, "(Press Return to start level)")
  end

  def toggle_hint!
    @hint = !@hint
  end

  def show_controls!
    @last_message = "Use arrow keys to move.\n"+
      "Press Space to pick up boots, Ctrl to drop boots, Tab to change boots.\n" +
      "Press 'j' to show where you can move (and j again to hide)."
  end

end

def play(ops)
  w = GameWindow.new(ops)
  puts "Boots Puzzle v#{BP_VERSION}"
  puts "Boots Puzzle is free software. See LICENSE for more information."
  puts "Copyright (c) 2008 Pierre-Henri Trivier"
  w.show
end

