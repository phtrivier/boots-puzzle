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

require 'puzzle'
require 'plugins'
require 'action'
require 'adventure'

require 'sdl'
require 'game_modes'
require 'text_fitter'
require 'text_cutter'
require 'adventure_loader'
require 'button'
# --------------------------------------------
# Game UI

class GameWindow

  attr_reader :puzzle, :font

  # Maximum dimension of puzzles
  PUZZLE_MAX_H = Puzzle::MAX_H
  PUZZLE_MAX_W = Puzzle::MAX_W

  # ---------------------------------
  # SDL Specific part

  def init_screen(w,h)
    SDL.init( SDL::INIT_VIDEO )
    @screen = SDL::setVideoMode(w,h,24,SDL::SWSURFACE)
    @white = @screen.mapRGB 255,255,255
  end

  def load_sdl_image(path)
     SDL::Surface.load(path)
  end

  def draw_to_screen(img, x, y)
    @screen.put(img, x, y)
  end

  # Draw a rectangle
  # Point order is as follow :
  # O x1,y1 --- O #x2,y1
  # |           |
  # O x1,y2 --- O x2,y2
  def draw_rectangle(x1,y1,x2,y2,color)
    # TODO : Make it possible to use w / h instead
    # so fix all the calls to draw_rectangle
    @screen.draw_rect(x1, y1, (x2-x1), (y2 -y1), color)
  end

  def load_default_font
    SDL::TTF.init
    res = SDL::TTF.open("#{@prefix}/gui/fonts/VeraBd.ttf",14)
    res.style = SDL::TTF::STYLE_NORMAL
    res
  end

  def draw_text_line(line, x, y, color)
    r,g,b = @screen.get_rgb(color)
    @font.draw_solid_utf8(@screen, line, x, y, r, g, b)
  end

  def set_caption(txt)
    SDL::WM.set_caption(txt, "")
  end

  # ------------------------
  # Relatively framework-agnostic part of the game

  SCREEN_W = 800
  SCREEN_H = 600

  TILE_SIZE = 32
  WINDOW_OFF_X = 20
  WINDOW_OFF_Y = 20

  RECTANGLE_OFF = 5

  QUOTE_TEXT_X = 50
  QUOTE_TEXT_Y = 110

  QUOTE_AUTHOR_X = 450
  QUOTE_AUTHOR_Y = 400

  QUOTE_TEXT_ZONE_W = 300
  QUOTE_AUTHOR_ZONE_W = 200

  START_TEXT_X = 50
  START_TEXT_Y = 450

  BOOTS_UI_X = 738
  BOOTS_UI_Y = 25
  BOOTS_UI_DELTA = 25

  BOOTS_MAX_COUNT = 3

  BUTTONS_X = 710
  BUTTONS_Y = 205
  BUTTONS_W = 70
  BUTTONS_H = 30
  BUTTONS_DELTA = 5

  MESSAGE_ZONE_W = 750
  MESSAGE_ZONE_H = 110

  def initialize(props)
    init_screen(SCREEN_W,SCREEN_H)

    @prefix = props[:prefix] || "."

    @font = load_default_font()

    @fitter = TextFitter.new(@font, MESSAGE_ZONE_W)
    @message_cutter = TextCutter.new(@fitter)
    @text_h = @font.height

    @quote_text_fitter = TextFitter.new(@font, QUOTE_TEXT_ZONE_W)
    @quote_text_cutter = TextCutter.new(@quote_text_fitter)

    @quote_author_fitter = TextFitter.new(@font, QUOTE_AUTHOR_ZONE_W)
    @quote_author_cutter = TextCutter.new(@quote_author_fitter)

    @last_message = nil

    load_adventure(props)

    # Hints at startup by default
    @hint = false

    init_hints_images

    init_adventure_images

    init_buttons

    @images = { }

    @player_img = load_sdl_image(to_global_image_path(@puzzle.player.src))

    go_to_splash_screen

    set_caption("Boots Puzzle v#{BP_VERSION} -- #{@adventure.name}")

  end

  def go_to_splash_screen
    @game_mode = SplashScreenMode.new(self)
  end

  def init_buttons
    @buttons = ButtonGroup.new(BUTTONS_X, BUTTONS_Y, BUTTONS_W, BUTTONS_H, BUTTONS_DELTA)

    @buttons.add_button("Quit") do 
      quit
    end
    @buttons.add_button("Retry") do
      reload_current_puzzle!
    end
    @buttons.add_button("Help") do
      show_controls!
    end
    @buttons.add_button("Home") do
      go_to_splash_screen
    end

  end
  
  def load_adventure(props)

    adventure_name = props[:adventure_name]
    adventure_path = props[:adventure_roots]

    @adventure_loader = AdventureLoader.new(@prefix, adventure_path)

    @adventure = @adventure_loader.load!(adventure_name)

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

  def reload_current_puzzle!
    # TODO : FACTOR WITH WHAT IS DONE THE FIRST TIME?
    @adventure.load_current_level!
    @puzzle = @adventure.current_level.puzzle
    init_puzzle
  end

  # Loads an image from the 'gui/img' folder
  # filename : name of the image file (eg background.png)
  def load_gui_image(filename)
    load_sdl_image("#{@prefix}/gui/img/#{filename}")
  end

  # Load the image for an hint
  def load_hint_image(dir)
    load_gui_image("hint_#{dir}.png")
  end

  def load_adventure_image(pic_filename)

#    default_path = "#{@prefix}/gui/img/#{pic_filename}"
##    adventure_image_path = "#{@prefix}/adventures/#{@adventure.name}/img/#{pic_filename}"
#     adventure_image_path = @adventure_loader.image_path(pic_filename)
#     if (File.exists?(adventure_image_path))
#       path = adventure_image_path
#     else
#       path = default_path
#     end

    path = to_clever_image_path(pic_filename)
    load_sdl_image(path)
  end

  def update
    @game_mode.update
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

  # TODO : RENAME "draw_all"
  def draw_puzzle

    @x0 = WINDOW_OFF_X
    @y0 = WINDOW_OFF_Y
    @s = TILE_SIZE

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

    if (@hint)
      draw_hint
    end

  end

  # Draws an image of an arrow on each cell that is walkable and
  # reachable using the current boots
  def draw_hint
    h = @puzzle.player.current_boots.hints(@puzzle)
    h.each do |dir, pos|
      i,j = pos
      draw_on_cell(@hints_images[dir], i, j)
    end
  end

  def draw_background
    draw_to_screen(@bg_image, 0, 0)
    # Draw a rectangle around the game area
    d = RECTANGLE_OFF
    draw_rectangle(@x0-d, @y0-d, @x0 + PUZZLE_MAX_W*@s + d, @y0 + PUZZLE_MAX_H*@s + d, @white)
  end

  def to_screen_coords(i,j)
    x = @x0 + j * @s
    y = @y0 + i * @s
    [x,y]
  end

  def draw_on_cell(img, i,j)
    x,y = to_screen_coords(i,j)
    draw_to_screen(img, x,y)
  end

  def draw_player
    i,j = @puzzle.player.pos
    draw_on_cell(@player_img, i, j)
  end

  def draw_cell(i,j,c)
    draw_on_cell(get_image(c), i, j)
  end

  def draw_boot(i,j,c,b)
    draw_on_cell(get_image(b), i, j)
  end

  def draw_ui
    draw_boots_ui
    draw_message_ui
    draw_buttons
  end

  def draw_buttons
    @buttons.each do |b|
      draw_rectangle(b.x, b.y, b.x + b.w, b.y + b.h, @white)
      # TODO : nicely compute the ideal x position, assuming
      # the button is whide enough
      draw_text_line(b.label, b.x + RECTANGLE_OFF, b.y + RECTANGLE_OFF, @white)
    end
  end

  # Draw the part of the UI where the current boot is displayed
  def draw_boots_ui
    @boots_ui_x0 = BOOTS_UI_X
    @boots_ui_y0 = BOOTS_UI_Y
    interval = BOOTS_UI_DELTA

    x = @boots_ui_x0
    y = @boots_ui_y0

    # Draw a nice line around everything
    draw_rectangle(x-10, y-10, x + @s + 10, y + 5 + (@s*BOOTS_MAX_COUNT) + (interval*2) + 10, @white)

    # Draw each boots, surrounding the selected one
    @puzzle.player.each_boots do |boot, selected|

      boot_image = get_image(boot)

      draw_to_screen(boot_image, x, y)

      if (selected)
        # Draw a quad around the selected one ...
        draw_rectangle(x-RECTANGLE_OFF, y-RECTANGLE_OFF, x+@s+RECTANGLE_OFF, y+@s+RECTANGLE_OFF, @white)
      end

      y = y + @s + interval

    end

  end

  def draw_message_ui
    y0 = @y0 + @s*PUZZLE_MAX_H + 5 + 10
    x1 = @x0 + MESSAGE_ZONE_W + 10
    height = MESSAGE_ZONE_H

    draw_rectangle @x0 - 5, y0, x1, y0 + height, @white

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
      draw_text_line(line, x,y, @white)
      y = y + @text_h + 2
    end
  end

  # Handlers for the messages
  def handle_message(ops)
    @last_message = ops[:msg]
  end

  # Load an image from its source.
  # It will first try and locate the image in the globally available "plugins"
  # folder. Than it will try and locate it in the adventure's img/ folder.
  def load_image(src)
    load_sdl_image(to_clever_image_path(src))
  end

  # Locate the image (it must be available globally ?)
  def to_global_image_path(src)
    "#{@prefix}/plugins/#{src}"
  end

  # This tries to locate an image by its source, looking into 
  # several locations 
  # * globally (assuming the paths starts as a subfolder of the global plugins/ folder)
  # * in the default ui img folder (gui/img"
  # * in the adventure's own /img folder
  # * in the adventure's /plugins folder
  def to_clever_image_path(src)
    path = nil
    potential_paths = ["#{@prefix}/plugins/#{src}", 
                       "#{@prefix}/gui/img/#{src}", 
                       @adventure_loader.global_image_path(src),
                       @adventure_loader.plugins_image_path(src)]

    potential_paths.each do |p|
      if File.exists?(p)
        path = p
        break
      end
    end
    
    path

  end

  def get_image(cell)
    if (not @images.has_key?(cell.src))
      @images[cell.src] = load_image(cell.src)
    end
    res = @images[cell.src]
    res
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
    draw_to_screen(@splash_screen, 0, 0)
  end

  def draw_end_screen
    draw_to_screen(@end_screen, 0, 0)
  end

  def draw_quote
    draw_to_screen(@bg_image, 0, 0)
    safe_draw_text(QUOTE_TEXT_X,QUOTE_TEXT_Y, @quote_text_cutter, "'#{@puzzle.quote.text}'")
    if (@puzzle.quote.author != nil)
      safe_draw_text(QUOTE_AUTHOR_X, QUOTE_AUTHOR_Y, @quote_author_cutter , @puzzle.quote.author)
    end
    safe_draw_text(START_TEXT_X, START_TEXT_Y, @message_cutter, "(Press Return to start level)")
  end

  def toggle_hint!
    @hint = !@hint
  end

  def show_controls!
    @last_message = "Use arrow keys to move.\n"+
      "Press Space to change boots, Ctrl to drop boots.\n" +
      "Press 'j' to show or hide where you can move."
  end

  def show

    # TODO(pht) test this
    SDL::Key.enable_key_repeat(10,10)

    # Enter the main loop ....
    loop do
      # Maybe here, wait_for_key, but raise an exception
      # every so often, so that you can update things in the maze
      # at regular interval (just to say 'hey, men, 2 seconds have passed', 
      # move a bit)
      pressed_key = wait_for_key
      @game_mode.update(pressed_key)
      @game_mode.draw
      # Update screen
      @screen.update_rect(0,0,0,0)
      SDL.delay(60)
    end
  end

  def wait_for_key
    res = nil
    # handle keystrokes
    while (res == nil) and (event = SDL::Event2.poll)
      case event
      when SDL::Event2::MouseButtonUp
        check_button_clicks(event)
      when SDL::Event2::Quit then exit
      when SDL::Event2::KeyDown
        res = event.sym
      end
      if (res == nil)
        SDL.delay(60)
      end
    end
# Could this be the cause of the CPU-intensitivy ?
#    SDL::Key.scan
    res
  end

  def check_button_clicks(event)
    @buttons.each do |button|
      button.check(event)
    end
  end

end

def play(ops)
  w = GameWindow.new(ops)
  puts "Boots Puzzle v#{BP_VERSION}"
  puts "Boots Puzzle is free software. See LICENSE for more information."
  puts "Copyright (c) 2008 Pierre-Henri Trivier"
  w.show
end

