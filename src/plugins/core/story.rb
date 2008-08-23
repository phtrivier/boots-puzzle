# Boots Puzzle - story.rb
#
# Functions to define stories
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

class Story

#   def self.name_for(puzzle_name, klass_name = nil)
#     klass_name = Puzzle.name_for(puzzle_name) unless klass_name
#     "#{klass_name}Story"
#   end

  def self.for(str, klass_name = nil, &block)

    name = Name.new(str, { :puzzle_clas_name => klass_name})
    klass_name = name.story_class_name

#    klass_name = Story.name_for(puzzle_name) unless klass_name

    klass = Module.new

    klass.instance_eval do
      define_method :init_story , block
    end

    Kernel.const_set(klass_name, klass)

  end

end
