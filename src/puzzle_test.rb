# Boots Puzzle - puzzle_test.rb
#
# Tests for the puzzle class
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
require 'rubygems'
require 'mocha'

require 'puzzle'

class PuzzleTest < Test::Unit::TestCase

  def assert_point_equal(i,j,k,l)
    assert_equal(i,k, "Line index should be equals")
    assert_equal(j,l, "Column index should be equals")
  end

  # -----------------------

  class NoDimPuzzle < Puzzle

  end

  class DimPuzzle < Puzzle
      dim 1,2
      row "#"
      row "#"
  end

  def test_reads_dimension
    p = DimPuzzle.new
    assert_equal 1, p.w
    assert_equal 2, p.h

    q = NoDimPuzzle.new
    assert_equal nil, q.w
    assert_equal nil, q.h

  end

  class RowsPuzzle < Puzzle
    dim 3,2
    row "###"
    row "I-O"
  end

  def test_reads_rows
    p = RowsPuzzle.new
    assert_equal Wall, p.cells[0][0].class
    assert_equal Wall, p.cells[0][1].class
    assert_equal Wall, p.cells[0][2].class

    assert_equal In, p.cells[1][0].class
    assert_equal Walkable, p.cells[1][1].class
    assert_equal Out, p.cells[1][2].class
  end

  class ExtendedCell
  end

  class ExtendingCellTypePuzzle < Puzzle
    dim 2,1
    row "@@"

    def extend_cell(c)
       res = nil
       if (c == "@")
         res =  ExtendedCell.new
       end
       res
     end

  end

  def test_rows_definition_are_extendible
    p = ExtendingCellTypePuzzle.new
    assert_equal ExtendedCell, p.cell(0,1).class
  end

  class InvalidCharPuzzle < Puzzle
    dim 1,1
    row "%"
  end

  def test_invalid_cell_definition_with_no_extension_cause_errors
    begin
      p = InvalidCharPuzzle.new
      assert(false, "Bad char")
    rescue BadCellCharError => e
      assert_equal "%", e.char
    end
  end

  class BadDimensionPuzzle < Puzzle
    dim 3,2
    row "##"
    row "##"
  end

  def test_checks_dimension_width
    begin
      p = BadDimensionPuzzle.new
      assert(false, "Bad dimension")
    rescue BadDimension => e
      assert_equal("Bad row : ##, expecting 3 cell(s)", e.message)
    end
  end

  class BadDimensionPuzzle2 < Puzzle
    dim 3,2
    row "###"
  end

  def test_checks_dimension_height
    begin
      p = BadDimensionPuzzle2.new
      assert(false, "Bad dimension")
    rescue BadDimension => e
      assert_equal("Bad puzzle ; found 1 row(s), expecting 2", e.message)
    end
  end

  class PuzzleIter < Puzzle
    dim 2,2
    row "#I"
    row "-O"
  end

  def test_iterate_over_cells

    p = PuzzleIter.new

    res = []

    p.each_cell do |i,j,c|

      res << [i,j,c.class]

    end

    assert_equal([0,0, Wall], res[0])
    assert_equal([0,1, In], res[1])
    assert_equal([1,0, Walkable], res[2])
    assert_equal([1,1, Out], res[3])

  end

  def test_knows_location_of_in_out
    i,j = PuzzleIter.new.in
    assert_point_equal(0,1,i,j)
    i,j = PuzzleIter.new.out
    assert_point_equal(1,1,i,j)
  end

  class NoInOut < Puzzle
    dim 2, 2
    row "##"
    row "--"
  end

  def test_returns_nil_nil_if_no_in_out

    i,j = NoInOut.new.in
    assert_point_equal(nil,nil,i,j)
    i,j = NoInOut.new.out
    assert_point_equal(nil,nil,i,j)

  end

  class TestPuzzle < Puzzle
    dim 2,2
    row "#I"
    row "O-"
  end

  def test_knows_whether_a_position_is_walkable
    p = TestPuzzle.new
    assert !p.walkable?(0,0)
    assert p.walkable?(0,1)
    assert p.walkable?(1,0)
    assert p.walkable?(1,1)
  end

  def test_player_starts_at_entry
    pu = TestPuzzle.new
    pu.enters_player!

    p = pu.player

    assert_not_nil p
    assert_equal [0,1], p.pos
    assert_equal 0, p.i
    assert_equal 1, p.j
  end

  def test_refuses_to_enter_player_if_no_entry
    pu = NoInOut.new
    begin
      pu.enters_player!
      assert(false, "Should not be possible to enter a puzzle with no entry")
    rescue NoEntry
    end
  end

  def test_knowns_whether_a_cell_is_valid
    pu = TestPuzzle.new
    assert !pu.valid?(-1,0)
    assert !pu.valid?(3,0)
    assert !pu.valid?(0,-1)
    assert !pu.valid?(0,3)
    assert pu.valid?(1,0)
  end

  def test_moves_the_player_in_the_puzzle_using_default_boots
    pu = TestPuzzle.new
    pu.enters_player!

    pu.try_move!(:right)
    assert_equal [0,1], pu.player.pos

    pu.try_move!(:down)
    assert_equal [1,1], pu.player.pos

    pu.try_move!(:up)
    assert_equal [0,1], pu.player.pos

    pu.try_move!(:left)
    assert_equal [0,1], pu.player.pos

    pu.try_move!(:down)
    assert_equal [1,1], pu.player.pos

    pu.try_move!(:left)
    assert_equal [1,0], pu.player.pos
  end

  def test_trying_to_move_ask_players_current_shoes_to_move
    pu = TestPuzzle.new

    pu.enters_player!
    m = mock()
    pu.player.current_boots=m

    m.expects(:try_move!).with(pu, :up)

    pu.try_move!(:up)
  end

  def test_walking_on_a_cell_calls_its_corresponding_walk_method
    pu = TestPuzzle.new
    c = mock()
    c.expects(:walkable?).returns(true)
    c.expects(:walk!).with(pu)

    pu.set_cell(1,1,c)
    assert_equal(c, pu.cell(1,1))
    pu.enters_player!

    pu.try_move!(:down)

  end

  class SpecialPuzzle < Puzzle
    dim 2,2
    row "--"
    row "IO"

    named_cells do
      named_cell :bar, 0 ,0
      named_cell :foo, 0, 1
    end

  end

  def test_cell_can_be_referenced_and_located_by_name
    pu = SpecialPuzzle.new
    assert_equal pu.cell(0,0), pu.cell_by_name(:bar)
    assert_equal pu.cell(0,1), pu.cell_by_name(:foo)
    assert_nil pu.cell_by_name(:baz)
  end

  def test_events_can_be_added
    pu = SpecialPuzzle.new
    assert_equal Walkable, pu.cell_by_name(:bar).class
    pu.story_event(:bar, Wall) do |puzzle|
    end
    assert_equal Wall, pu.cell_by_name(:bar).class
  end

  module PuzzleStory
    attr_accessor :called
    @called = false

    def init_story
      story_event(:bar, Walkable) do |puzzle|
        @called = true
      end
    end
  end

  class PuzzleWithStory < SpecialPuzzle
    dim 2,2
    row "--"
    row "IO"

    named_cells do
      named_cell :bar, 0 ,0
      named_cell :foo, 0, 1
    end

    story PuzzleTest::PuzzleStory
  end

  def test_loads_story_if_relevant
    pu = PuzzleWithStory.new
    assert_equal Walkable, pu.cell_by_name(:bar).class
    pu.enters_player!
    assert !pu.called
    pu.try_move!(:up)
    assert pu.called
    pu.called = false
    pu.try_move!(:right)
    assert !pu.called
  end

  def test_shout_if_an_event_is_defined_on_a_non_existing_cell
    pu = PuzzleWithStory.new
    begin
      pu.story_event(:baz, Cell) do |puzzle|
      end
    rescue NoCellError => e
      assert_equal "No cell named baz in puzzle", e.message
    end
  end

  def test_cell_can_be_set_by_name
    pu = PuzzleWithStory.new
    assert_equal  Walkable, pu.cell_by_name(:bar).class
    pu.set_cell_by_name(:bar, Wall.new)
    assert_equal  Wall, pu.cell_by_name(:bar).class
  end

end
