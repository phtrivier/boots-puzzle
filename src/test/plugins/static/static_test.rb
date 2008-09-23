# Boots Puzzle - static_test.rb
#
# Test for the 'static' plugin
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

require 'plugin_test_case'

class StaticPluginTest < PluginTestCase
  tested_plugin :static

  class TestPuzzle < Puzzle
    dim 2,2
    rows do
      row "I-"
      row "-O"
    end
  end

  class TestStaticCell < StaticCell
    attr_reader :dir
    def static_contact!(puzzle, dir)
      @dir = dir
    end
  end

  def test_when_you_walk_on_static_you_dont_move
    pu = TestPuzzle.new
    c = TestStaticCell.new
    pu.set_cell(0,1,c)
    pu.enters_player!
    pu.try_move!(:right)
    assert_equal [0,0], pu.player.pos
    assert_equal :right, c.dir
  end

end
