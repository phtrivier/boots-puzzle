# Boots Puzzle - boots.rb
#
# Boots class (what the player use to walk.
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

class Boots

  def try_move!(puzzle, dir)
    ni,nj = new_position(puzzle, dir)
    try_move_to( puzzle, ni,nj)
  end

  def new_position(puzzle, dir)
    raise RuntimeError.new("Should not instanciate Boots and call new_position. Subclass instead")
  end

  def try_move_to(puzzle, i,j)
    if (puzzle.valid?(i,j) and puzzle.walkable?(i,j))
      puzzle.player.move!([i,j])
      puzzle.cell(i,j).walk!(puzzle)
    end
  end

  def src
    raise RuntimeError.new("Should not instanciate Boots and call src. Subclass it.")
  end
end


# Default boots for the player,
# which walks one cell at a time.
class BareFeet < Boots
  def new_position( puzzle, dir)
    i,j = puzzle.player.pos
    case dir
      when :up then [i-1, j]
      when :down then [i+1, j]
      when :left then [i, j-1]
      when :right then [i, j+1]
    end
  end

  def src
     "core/img/bare_feet.png"
  end
end

class DoubleBoots < Boots
  def new_position( puzzle, dir)
    i,j = puzzle.player.pos
    case dir
      when :up then [i-2, j]
      when :down then [i+2, j]
      when :left then [i, j-2]
      when :right then [i, j+2]
    end
  end

  def src
    "core/img/double_boots.png"
  end

end
