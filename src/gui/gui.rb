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

# Init the plugin system
Plugins.init("src/plugins")
Plugins.read_manifests

# TODO : add a better HELP
def usage
  puts "----------------------------------------------------"
  puts "Usage : 'play_puzzle file_name class_name'"
  puts "Example : 'ruby play_puzzle foo_puzzle.rb FooPuzzle'"
end

require 'action'

require 'adventure'

# --------------------------------------------
# Game UI

class GameWindow < Gosu::Window

  attr_reader :puzzle

  White = Gosu::Color.new(0xffffffff)
  # Maximum dimension of puzzles
  H = 10
  W = 16

  def initialize
    super(640, 480, false)
    self.caption = "Puzzle Game"

    @bg_image =  Gosu::Image.new(self, "src/gui/img/background_spirale.png", false)

    @adventure = nil

    if (ARGV[1] != nil)
      @puzzle = Puzzle.load(ARGV[1], ARGV[2]) do |file_name, klass_name, e|
        puts "Unable to load puzzle #{klass_name} from file #{file_name}, #{e}"
        usage
        exit(-1)
      end
    else

      @adventure = Adventure.new
      @adventure.load!(File.open("src/adventures/foobar/adventure.yml"))
      @adventure.load_plugins!

      if (@adventure.has_next_level?)
        @adventure.load_next_level!
        @puzzle = @adventure.current_level.puzzle
      end

    end

    @puzzle.enters_player!

    @font = Gosu::Font.new(self, Gosu::default_font_name, 20)

    @images = { }

    @player_img = Gosu::Image.new(self, to_image_path("core/img/player.png"), false)

    @actions = {  :next_boots => NextBootsAction.new(self, Gosu::Button::KbTab) ,
      :up => MoveAction.new(self, Gosu::Button::KbUp, :up),
      :down => MoveAction.new(self, Gosu::Button::KbDown, :down),
      :right => MoveAction.new(self, Gosu::Button::KbRight, :right),
      :left => MoveAction.new(self, Gosu::Button::KbLeft, :left),
      :pick_boots => PickBootsAction.new(self, Gosu::Button::KbSpace),
      :drop_boots => DropBootsAction.new(self, Gosu::Button::KbLeftControl)
    }

  end

  def update
    # Move
    @actions.each do |name, action|
      action.evaluate
    end

    # Change level if required
    if (@adventure.current_level.finished?)
      puts "Congratulations, you finished this level !!"
      if (@adventure.has_next_level?)
        @adventure.load_next_level!
        @puzzle = @adventure.current_level.puzzle
        @puzzle.enters_player!
      else
        puts "Congratulations, you finished this adventure !!"
        puts "Thanks for playing !!"
        exit(0)
      end
    end

  end

  def draw
#    @font.draw("Hello world !", 10, 10, ZOrder::UI, 1.0, 1.0, 0xffffff00)
    draw_puzzle
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

  end

  def draw_background
    @bg_image.draw(0,0,ZOrder::UI)

    # Draw a rectangle around the game area
    draw_rectangle(@x0-5, @y0-5, @x0 + W*@s + 5, @y0 + H*@s + 5, White)
#    draw_rectangle(@x0-3, @y0-3, @x0 + w*@s + 3, @y0 + h*@s + 3, White)

  end

  def to_screen_coords(i,j)
    x = @x0 + j * @s
    y = @y0 + i * @s
    [x,y]
  end

  def draw_player
    i,j = @puzzle.player.pos

    x,y = to_screen_coords(i,j)

    @player_img.draw(x,y, ZOrder::UI)
  end

  def draw_cell(i,j,c)

    x,y = to_screen_coords(i,j)

    i = get_image(c)
    i.draw(x,y, ZOrder::UI)

  end

  def draw_boot(i,j,c,b)

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
    "src/plugins/#{src}"
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

end

def play
  w = GameWindow.new
  w.show
end
