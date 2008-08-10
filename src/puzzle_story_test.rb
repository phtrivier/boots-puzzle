# Boots Puzzle - puzzle_story_test.rb
#
# More tests for the puzzle class, dealing
# with the story and such.
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

class PuzzleStoryTest < Test::Unit::TestCase

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

    story PuzzleStoryTest::PuzzleStory
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

  class NonSymetricPuzzle < Puzzle
    dim 3,2
    row "I--"
    row "--O"
  end

  def test_walking_outside_of_a_symetric_puzzle_is_not_possible
    pu = NonSymetricPuzzle.new

    assert_equal 3, pu.w
    assert_equal 2, pu.h

    pu.enters_player!
    pu.try_move!(:down)
    assert_equal [1,0], pu.player.pos
    assert !pu.valid?(2,0), "Position should be out of the puzzle's reach"
    pu.try_move!(:down)
    assert_equal [1,0], pu.player.pos
  end

  def test_creates_empty_puzzle
    pu = Puzzle.empty(5,6)
    assert_equal 5, pu.w
    assert_equal 6, pu.h

    assert_equal Walkable, pu.cell(2,2).class
  end

  def test_can_save_itself

    pu = NonSymetricPuzzle.new
    expected = ["class NonSymetricPuzzle < Puzzle",
                " dim 3,2",
                ' row "I--"',
                ' row "--O"',
                "end\n"
                ].join("\n")

    assert_equal expected, pu.serialize('NonSymetricPuzzle')

  end

  def test_saving_puzzle_with_named_cells

    pu = PuzzleWithStory.new

    ex =  ["class PuzzleWithStory < Puzzle",
           " dim 2,2",
           ' row "--"',
           ' row "IO"',
           '',
           ' named_cells do',
           '  named_cell :bar, 0, 0',
           '  named_cell :foo, 0, 1',
           ' end',
           'end'].join("\n") + "\n"

    assert_equal ex, pu.serialize("PuzzleWithStory")

  end

  def test_removing_the_name_of_a_cell
    pu = PuzzleWithStory.new

    assert_not_nil pu.cell_by_name(:foo)
    pu.unname_cell(:foo)
    assert_nil pu.cell_by_name(:foo)

    begin
      pu.unname_cell(:baz)
      bad("Should not be possible to remove unexisting cell")
    rescue NoCellError => e
      assert_equal "No cell named baz in puzzle", e.message
    end

  end

  def bad(msg)
    assert false, msg
  end

  class DummyBoots < BareFeet
  end

  def test_add_boots_on_puzzle
    pu = PuzzleWithStory.new

    pu.boot 0,1,DummyBoots

    assert_nil pu.boot_at(0,0)
    assert_equal DummyBoots, pu.boot_at(0,1).class

    pu.remove_boot 0,1
    assert_nil pu.boot_at(0,1)

    begin
      pu.remove_boot 0,0
      bad("No boot here")
    rescue NoBootError => e
      assert_equal "No boots at position 0,0", e.message
    end

  end

end
