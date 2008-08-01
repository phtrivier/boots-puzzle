# Boots Puzzle - cell.rb
#
# Cells of the puzzles
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


class Cell

  # This might be redefined if needed
  def walkable?
    false
  end

  def self.walkable(b=true)
    self.instance_eval do
      define_method :walkable? do
        return b
      end
    end
  end

  def src
    "img/#{self.class.name.downcase}.png"
  end

  # Make something happen when
  # the player walks in a given cell.
  # @param puzzle (so that funny stuff can happen)
  def walk!(puzzle)
  end

  def meta
    class << self
      self
    end
  end

end

class Wall < Cell
end

class Walkable < Cell
  walkable
end

class In < Walkable
end

class Out < Walkable
end
