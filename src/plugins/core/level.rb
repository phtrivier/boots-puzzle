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

class Level

  attr_reader :puzzle_file, :puzzle_class_name
  attr_reader :puzzle

  def initialize(file, klass_name)
    @puzzle_file = file
    @puzzle_class_name = klass_name
    @puzzle = nil
  end

  def puzzle_file_path(prefix)
    "#{prefix}/#{@puzzle_file}"
  end

  def story_file_path(prefix)
    "#{prefix}/#{@puzzle_file}_story"
  end

  def load!(prefix)
    begin
      #puts "Trying story at #{story_file_path(prefix)}"
      require story_file_path(prefix)
    rescue LoadError => e
    end
    #puts "Trying puzzle at #{puzzle_file_path(prefix)}"
    require puzzle_file_path(prefix)
    # Ugly isn't it ?
    cmd = "@puzzle = #{@puzzle_class_name}.new"
    # puts "Cmd : #{cmd}"
    instance_eval(cmd)
  end

  def finished?
    @puzzle.player.pos == @puzzle.out
  end

end
