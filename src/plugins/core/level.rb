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

class Level

  include Log4r

  attr_reader :puzzle_file, :puzzle_class_name
  attr_reader :puzzle

  def initialize(file, klass_name=nil)
    @puzzle_file = file
    if (klass_name != nil)
      @puzzle_class_name = klass_name
    else
      @puzzle_class_name = Puzzle.name_for(file)
    end
    @puzzle = nil
    @log = Logger.new 'bp::level'
  end

  def puzzle_file_path(prefix)
    "#{prefix}/#{@puzzle_file}"
  end

  def story_file_path(prefix)
    "#{prefix}/#{@puzzle_file}_story"
  end

  def load!(prefix)
    begin
      @log.info {  "Trying story at #{story_file_path(prefix)}" }
      require story_file_path(prefix)
    rescue LoadError => e
    end
    @log.info {  "Trying puzzle at #{puzzle_file_path(prefix)}" }
    require puzzle_file_path(prefix)
    # Ugly isn't it ?
    cmd = "@puzzle = #{@puzzle_class_name}.new"
    @log.debug { "Cmd to load the class : #{cmd}" }
    instance_eval(cmd)
  end

  def finished?
    @puzzle.player.pos == @puzzle.out
  end

end
