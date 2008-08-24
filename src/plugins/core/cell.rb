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

require 'naming'

class Cell

  include Naming

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
    "core/img/#{self.class.name.downcase}.png"
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

  @@types_by_letter = { }
  @@letters_by_type = { }

  def self.letter(l)
    k = self
    @@types_by_letter[l] = k
    @@letters_by_type[k] = l

    # Provide an accessor for each cell, after all...
    self.instance_eval do
      define_method :letter do
        l
      end
    end

  end

  def self.type_by_letter(l)
    @@types_by_letter[l]
  end

  def self.letter_by_type(type)
    @@letters_by_type[type]
  end

  # Creates a new class for a cell, for a given plugin
  def self.for_plugin(plugin_name, props={}, &block)
    cell_class_name = props[:name]
    if (cell_class_name == nil)
      cell_class_name = Naming.to_camel_case(plugin_name) + "Cell"
    end

    cell_parent_class = props[:parent]
    if (cell_parent_class == nil)
      cell_parent_class = Cell
    end

    cell_class = Class.new(cell_parent_class)

    cell_class.class.instance_eval do

      define_method :img do |image_file_name|

        define_method :src do
          "#{plugin_name}/img/#{image_file_name}"
        end

      end

    end

    if (block_given?)
      cell_class.instance_eval(&block)
    end
    Kernel.const_set(cell_class_name, cell_class)

  end

  def img
  end

end

class Wall < Cell
  letter "#"
end

class Walkable < Cell
  walkable
  letter "-"
end

class In < Walkable
  letter "I"
end

class Out < Walkable
  letter "O"
end
