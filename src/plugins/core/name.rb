# Boots Puzzle - name.rb
#
# Class to contain the various names of puzzle
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

require "naming"

class Name

  include Naming

  attr_reader :base_name
  attr_reader :puzzle_file_name, :puzzle_class_name
  attr_reader :story_file_name, :story_class_name

  def  initialize(str, ops = {})
    @str = str
    if (is_file_name?)
      @puzzle_file_name = @str
      compute_base_name(true)
    else
      compute_base_name(false)
      @puzzle_file_name = "#{@base_name}.rb"
    end

    if (ops[:puzzle_class_name])
      @puzzle_class_name = ops[:puzzle_class_name]
    else
      compute_puzzle_class_name
    end
    compute_story_file_name
    compute_story_class_name

  end

  def ends_with_puzzle?(str)
    r = Regexp.new("(.*)(_puzzle|_puzzle\.rb)$")
    r.match(str)
  end

  def ends_with_rb?(str)
    r = Regexp.new("(.*)\.rb$")
    r.match(str)
  end

  def compute_base_name(is_a_file)

    end_of_str = @str.split("/")[-1]

    # Does it ends by puzzle or puzzle.rb ?
    m = ends_with_puzzle?(end_of_str)
    if (m == nil)
      # Does it ends with .rb ?
      m = ends_with_rb?(end_of_str)
      if (m == nil)
        @base_name = end_of_str + "_puzzle"
      else
        raise NameError.new("Cannot compute a puzzle base name for #{@str}")
      end
    else
      @base_name = m[1] + "_puzzle"
    end
  end

  def compute_puzzle_class_name
    @puzzle_class_name = Naming.to_camel_case(@base_name)
  end

  def compute_story_file_name

    if (ends_with_rb?(@puzzle_file_name))
      @story_file_name = @puzzle_file_name[0..-4] + "_story.rb"
    else
      @story_file_name = @puzzle_file_name + "_story"
    end

  end

  def compute_story_class_name
    @story_class_name = @puzzle_class_name + "Story"
  end

  def is_file_name?
    @str.include?("/")
  end

end
