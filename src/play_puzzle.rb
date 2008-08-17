# Boots Puzzle - play_puzzle
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

module SimplePuzzleStory
  def init_story
    story_event(:trap, Walkable) do |puzzle|
      # Add a way to know if the event occured already ...
      if (puzzle.cell_by_name(:begin).class != Wall)
        puzzle.set_cell_by_name(:begin, Wall.new)
        puzzle.set_cell_by_name(:end, Wall.new)
        # TODO : ADD A ZONE WITH MESSAGES
        puts "Ho no, the exit is locked now !!"
      end
    end
  end
end

class SimplePuzzle < Puzzle
  dim 4,3

  rows do
    row "###O"
    row "I##-"
    row "----"
  end

  named_cells do
    named_cell :begin,2,0
    named_cell :trap, 2, 1
    named_cell :end, 1, 3
  end

  boots do
    boot 2,3, DoubleBoots
  end

  story SimplePuzzleStory
end

# TODO : add a better HELP
def usage
  puts "----------------------------------------------------"
  puts "Usage : 'play_puzzle file_name class_name'"
  puts "Example : 'ruby play_puzzle foo_puzzle.rb FooPuzzle'"
end

# Actions for the game UI

# Subclasses should define :
# triggered? when the action should be activated
# released? when the action is done and should be considered finished
# act! what to do
class Action

  def initialize(w)
    @w = w
    @key_down = false
  end

  def evaluate
    if (triggered? and not @key_down)
      @key_down = true
      act!
    elsif (@key_down and released?)
      @key_down = false
    end
  end

end

class SingleKeyAction < Action
  def initialize(w, key)
    super(w)
    @k = key
  end

  def triggered?
    @w.button_down?(@k)
  end

  def released?
    !@w.button_down?(@k)
  end

end

class NextBootsAction < SingleKeyAction
  def act!
    @w.puzzle.player.next_boots!
  end
end

class MoveAction < SingleKeyAction
  def initialize(w, k, dir)
    super(w,k)
    @dir = dir
  end

  def act!
    @w.puzzle.try_move!(@dir)
  end
end

class PickBootsAction < SingleKeyAction
  def act!
    @w.puzzle.try_pick!
  end
end

class DropBootsAction < SingleKeyAction
  def act!
    @w.puzzle.try_drop!
  end
end

# --------------------------------------------
# Game UI

class GameWindow < Gosu::Window

  attr_reader :puzzle

  def initialize
    super(640, 480, false)
    self.caption = "Puzzle Game"

    if (ARGV[1] != nil && ARGV[2] != nil)
      @puzzle = Puzzle.load(ARGV[1], ARGV[2]) do |file_name, klass_name, e|
        puts "Unable to load puzzle #{klass_name} from file #{file_name}, #{e}"
        usage
        exit(-1)
      end

    else
      @puzzle = SimplePuzzle.new
    end

    @puzzle.enters_player!

    @font = Gosu::Font.new(self, Gosu::default_font_name, 20)

    @images = { }

    @player_img = Gosu::Image.new(self, to_image_path("img/player.png"), false)

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
    @actions.each do |name, action|
      action.evaluate
    end
  end

  def draw
    @font.draw("Hello world !", 10, 10, ZOrder::UI, 1.0, 1.0, 0xffffff00)
    draw_puzzle
  end

  def draw_puzzle

    @x0 = 20
    @y0 = 50
    @s = 32

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
    # draw_message_ui
    # draw_keys_ui
  end

  # Draw the part of the UI where the current boot is displayed
  def draw_boots_ui
    @boots_ui_x0 = 580
    @boots_ui_y0 = 30
    interval = 25

    x = @boots_ui_x0
    y = @boots_ui_y0

    # Draw a nice line around everything
    draw_rectangle(x-10, y-10, x + @s + 10, y + 5 + (@s*3) + (interval*2) + 10, Gosu::Color.new(0xffffffff))

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
