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
    story_event(:hello, Walkable) do |puzzle|
      puts "Hello, you walked here !!"
    end

    story_event(:almost_the_end, Walkable) do |puzzle|
      puzzle.set_cell_by_name(:hello, Wall.new)
      puts "Ho no, the entrance is locked now !!"
    end
  end
end

class SimplePuzzle < Puzzle
  dim 3,3
  row "###"
  row "I##"
  row "--O"

  named_cells do
    named_cell :hello, 2, 0
    named_cell :almost_the_end, 2, 1
  end

  story SimplePuzzleStory
end

# TODO : add a better HELP
def usage
  puts "----------------------------------------------------"
  puts "Usage : 'play_puzzle file_name class_name'"
  puts "Example : 'ruby play_puzzle foo_puzzle.rb FooPuzzle'"
end

class GameWindow < Gosu::Window
  def initialize
    super(640, 480, false)
    self.caption = "Puzzle Game"

    if (ARGV[0] != nil && ARGV[1] != nil)
      file_name = ARGV[0]
      klass_name = ARGV[1]
      begin
        require file_name
        @puzzle = Kernel.const_get(klass_name).new
      rescue LoadError,NameError => e
        puts "Unable to load puzzle #{klass_name} from file #{file_name}, #{e}"
        usage
        exit(-1)
      end

    else
      @puzzle = SimplePuzzle.new
    end

    @puzzle.enters_player!

#    @background_image = Gosu::Image.new(self, "media/Space.png", true)

#    @player = Player.new(self)
#    @player.warp(320, 240)

#    @star_anim = Gosu::Image::load_tiles(self, "media/Star.png", 25, 25, false)
#    @stars = Array.new

    @font = Gosu::Font.new(self, Gosu::default_font_name, 20)

    @images = { }

    @player_img = Gosu::Image.new(self, "img/player.png", false)

    @keys = {
      :up => [Gosu::Button::KbUp, Gosu::Button::GpUp],
      :down => [Gosu::Button::KbDown, Gosu::Button::GpDown],
      :right => [Gosu::Button::KbRight, Gosu::Button::GpRight],
      :left => [Gosu::Button::KbLeft, Gosu::Button::GpLeft]
    }

    @keys_down = { :up => false, :down => false, :right => false, :left => false }

  end

  def update
    [:up, :down, :right, :left].each do |dir|

      keys = @keys[dir]

      if (button_down? keys[0] or button_down? keys[1]) and !@keys_down[dir]
        @puzzle.try_move!(dir)
        @keys_down[dir] = true
      elsif (!button_down? keys[0] and !button_down? keys[1] and @keys_down[dir])
         @keys_down[dir] = false
      end

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
    end

    draw_player

  end

  def draw_player
    i,j = @puzzle.player.pos

    x = @x0 + j * @s
    y = @y0 + i * @s

    @player_img.draw(x,y, ZOrder::UI)

#     color = Gosu::Color.new(0xff00ffff)

#     draw_quad( x , y , color,
#                   x + ps, y, color,
#                   x, y + ps, color,
#                   x + ps, y+ ps, color,
#                   ZOrder::UI)

  end

  def draw_cell(i,j,c)

      x = @x0 + j * @s
      y = @y0 + i * @s

      # TODO : GET THE COLOR
      #color = get_color(c.color_name)
#       color = get_color(c)

      # DRAW A SQUARE OF THE COLOR, OF THE PROPER SIZE, ETC...
#      drawQuad (double x1, double y1, Color c1, double x2, double y2, Color c2, double x3, double y3, Color c3, double x4, double y4, Color c4, ZPos z, AlphaMode mode=amDefault)
      #puts "Drawing cell : #{i},#{j}, #{c}"

#       draw_quad( x, y, color,
#                   x + @s, y , color,
#                   x, y + @s, color,
#                   x + @s, y+ @s, color,
#                   ZOrder::UI)

    i = get_image(c)
    i.draw(x,y, ZOrder::UI)

  end

  def get_image(cell)
    if (not @images.has_key?(cell.src))
      @images[cell.src] = Gosu::Image.new(self, cell.src, false)
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

w = GameWindow.new
w.show
