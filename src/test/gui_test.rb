# Boots Puzzle - gui_test.rb
#
# Test for gui related functions
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

require 'gui_helper'

class GuiTest < BPTestCase

  include GuiHelper

  def test_keeps_text_that_fits_as_such
    text = "Hello world !"
    fitter = mock()
    fitter.expects(:fit?).with(text).returns(true)

    elements = cut_text(text, fitter)
    assert_equal [text], elements
  end

end
