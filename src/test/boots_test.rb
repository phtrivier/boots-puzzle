# Boots Puzzle - boots_test.rb
#
# Tests for Boots
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

require 'bp_test_case'

class BootsTest < BPTestCase

  def test_hints_depends_on_cells_being_valid_and_reachible

    i = 1
    j = 2
    b = BareFeet.new
    pu = mock()

    # UP : valid and reachable
    pu.expects(:valid?).with(i-1,j).returns(true)
    b.expects(:reachable?).with(pu,i-1,j).returns(true)

    # DOWN : invalid
    pu.expects(:valid?).with(i+1,j).returns(false)

    # LEFT : valid and unreachable
    pu.expects(:valid?).with(i, j-1).returns(true)
    b.expects(:reachable?).with(pu, i, j-1).returns(false)

    # RIGHT : valid and reachable
    pu.expects(:valid?).with(i,j+1).returns(true)
    b.expects(:reachable?).with(pu,i,j+1).returns(true)

    pl = mock()
    pu.expects(:player).returns(pl).times(4)
    pl.expects(:pos).returns([i,j]).times(4)

    h = b.hints(pu)

    assert_equal [i-1,j], h[:up]
    assert_equal [i, j+1], h[:right]
    assert_nil h[:down]
    assert_nil h[:left]

  end

end
