# Boots Puzzle - levelrb
#
# Level class
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

require 'log4r'

require 'name'

class Level

  include Log4r

  attr_reader :puzzle_file, :puzzle_class_name, :puzzle_name
  attr_reader :puzzle

  def initialize(str, klass_name=nil)

    @name = Name.new(str, { :puzzle_class_name => klass_name })
    @puzzle_name = @name.base_name
    @puzzle_file = @name.puzzle_file_name
    @puzzle_class_name = @name.puzzle_class_name
    @story_class_name = @name.story_class_name
    @story_file = @name.story_file_name

    @puzzle = nil
    @log = Logger.new 'bp::level'
  end

  def puzzle_file_path(prefix)
    "#{prefix}/#{@puzzle_file}"
  end

  def story_file_path(prefix)
    "#{prefix}/#{@story_file}"
  end

  def load!(prefix,should_load_story=true)
    @log.info {  "Trying puzzle at #{puzzle_file_path(prefix)}" }
    require puzzle_file_path(prefix)
    klass = Kernel.const_get(@puzzle_class_name)
    @puzzle = klass.new

    if (should_load_story)
      begin
        @log.info {  "Trying story at #{story_file_path(prefix)}" }
        require story_file_path(prefix)
        # Load the module
#        @puzzle.metaclass.include Kernel.const_get(@story_class_name)
        @log.info {  "Story module : #{Kernel.const_get(@story_class_name)}" }
        mod = Kernel.const_get(@story_class_name)

        @puzzle.init_story_from_module(mod)
        @log.info { "Puzzle properly loaded (used module #{@story_class_name})"}
        # Call the initers
        @puzzle.init_story
      rescue LoadError => e
        @log.info { "Could not load story : #{e}"}
      end
    end

  end

  def finished?
    @puzzle.player.pos == @puzzle.out
  end

end
