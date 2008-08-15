# Boots Puzzle - cell_test.rb
#
# Tests for the Cell class
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


require 'test/unit'

require 'cell'

class CellTest < Test::Unit::TestCase

  class WalkableCell < Cell
    walkable true
  end

  def test_knowns_whether_cell_is_walkable
    assert WalkableCell.new.walkable?
  end

  class NonWalkableCell < Cell
  end

  class NonWalkableCell2 < Cell
    walkable false
  end

  def test_returns_false_by_default
    assert !(NonWalkableCell.new.walkable?)
    assert !(NonWalkableCell2.new.walkable?)
  end

  class WalkableSuggar < Cell
    walkable
  end

  def test_syntactic_suggar_for_walkable
    assert WalkableSuggar.new.walkable?
  end

  class W1 < Cell
  end
  class W2 < Cell
    walkable
  end
  class W3 < Cell
    walkable
  end
  class W4 < W3
    walkable false
  end

  def test_walkable_follow_inheritence
    assert !(W1.new.walkable?)
    assert W2.new.walkable?
    assert W3.new.walkable?
    assert !(W4.new.walkable?)
  end

  def test_common_cells
    assert Walkable.new.walkable?
    assert In.new.walkable?
    assert Out.new.walkable?
    assert ! Wall.new.walkable?
  end

  def test_image_src_is_taken_from_class_name
    assert_equal "img/walkable.png", Walkable.new.src
    assert_equal "img/in.png", In.new.src
  end

  class CellWithLetter < Cell
    letter "Y"
  end

  def test_cells_register_their_letters

    assert_equal CellWithLetter, Cell.type_by_letter("Y")
    assert_equal "Y", Cell.letter_by_type(CellWithLetter)

    assert_equal "I", Cell.letter_by_type(In)
    assert_equal "O", Cell.letter_by_type(Out)
  end


end
