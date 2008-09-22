# Boots Puzzle - water_test.rb
#
# Tests for the 'water' plugin
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

class WaterTest < PluginTestCase
  tested_plugin :water

  def test_water_cells_exits
    c = WaterCell.new
    assert !c.walkable?
    assert_equal "~", c.letter
    assert_equal "water/img/water_cell.png", c.src
  end

  class RiverPuzzle < Puzzle
    dim 4,1
    rows do
      row "I-~O"
    end
    boots do
      boot 0,1,Palms
    end
  end

  def test_water_cells_are_reachible_by_palms
    p = Palms.new
    pu = RiverPuzzle.new
    assert !pu.cell(0,1).swimable?
    assert pu.cell(0,2).swimable?
    assert p.reachable?(pu, 0, 2)
    pu.enters_player!
    pu.try_move!(:right)
    pu.try_move!(:right)
    # You cannot move with your bare feets
    assert_equal 1, pu.player.pos[1]
    # Take palms, and it should work !
    pu.try_pick!
    pu.player.next_boots!
    pu.try_move!(:right)
    assert_equal 2, pu.player.pos[1]
  end

end
