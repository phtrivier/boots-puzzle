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

require 'bp_test_case'
require 'puzzle'

class PuzzleStoryTest < BPTestCase

  class SpecialPuzzle < Puzzle
    dim 2,2
    rows do
      row "--"
      row "IO"
    end

    named_cells do
      named_cell :bar, 0 ,0
      named_cell :foo, 0, 1
    end

  end

  def test_cell_can_be_referenced_and_located_by_name
    pu = SpecialPuzzle.new
    assert_equal pu.cell(0,0), pu.cell_by_name(:bar)
    assert_equal [0,0], pu.cell_position_by_name(:bar)
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

  def test_events_can_be_added_without
    pu = SpecialPuzzle.new
    assert_equal Walkable, pu.cell_by_name(:bar).class
    pu.story_event(:bar) do |puzzle|
    end
    assert_equal Walkable, pu.cell_by_name(:bar).class
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
    rows do
      row "--"
      row "IO"
    end

    named_cells do
      named_cell :bar, 0 ,0
      named_cell :foo, 0, 1
    end

  end

  def test_loads_story_if_relevant
    pu = PuzzleWithStory.new
    pu.init_story_from_module PuzzleStoryTest::PuzzleStory

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
    rows do
      row "I--"
      row "--O"
    end
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
                ' rows do',
                '  row "I--"',
                '  row "--O"',
                ' end',
                "end\n"
                ].join("\n")

    assert_equal expected, pu.serialize('NonSymetricPuzzle')

  end

  def test_saving_puzzle_with_named_cells

    pu = PuzzleWithStory.new

    ex =  ["class PuzzleWithStory < Puzzle",
           " dim 2,2",
           ' rows do',
           '  row "--"',
           '  row "IO"',
           ' end',
           '',
           ' named_cells do',
           '  named_cell :bar, 0, 0',
           '  named_cell :foo, 0, 1',
           ' end',
           'end'].join("\n") + "\n"

    ex2 =  ["class PuzzleWithStory < Puzzle",
           " dim 2,2",
           ' rows do',
           '  row "--"',
           '  row "IO"',
           ' end',
           '',
           ' named_cells do',
           '  named_cell :foo, 0, 1',
           '  named_cell :bar, 0, 0',
           ' end',
           'end'].join("\n") + "\n"



    assert ex == pu.serialize("PuzzleWithStory") || ex2 == pu.serialize("PuzzleWithStory")

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

  class PuzzleWithBoots < Puzzle
    dim 2,2

    rows do
      row "--"
      row "IO"
    end

    named_cells do
      named_cell :foo,0,0
    end

    boots do
      boot 0,1,DummyBoots
    end
  end

  def test_boots_loaded_in_class_definition
    pu = PuzzleWithBoots.new
    assert_not_nil pu.boot_at(0,1)
    assert_equal DummyBoots, pu.boot_at(0,1).class
    assert_nil pu.boot_at(0,0)
  end

  def test_boots_saved_in_class_definition
    pu = PuzzleWithBoots.new

    expected = ["class PuzzleWithBoots < Puzzle",
                " dim 2,2",
                ' rows do',
                '  row "--"',
                '  row "IO"',
                ' end',
                '',
                ' named_cells do',
                '  named_cell :foo, 0, 0',
                ' end',
                '',
                ' boots do',
                '  boot 0,1,PuzzleStoryTest::DummyBoots',
                ' end',
           'end'].join("\n") + "\n"

    assert_equal expected, pu.serialize("PuzzleWithBoots")

  end

  def test_boots_are_picked_somewhere_and_drop_somewhere
    pu = PuzzleWithBoots.new
    pu.enters_player!
    assert_not_nil pu.boot_at(0,1)
    assert_equal 1, pu.player.boots.size
    pu.try_move!(:up)
    pu.try_pick!
    assert_equal 1, pu.player.boots.size
    pu.try_move!(:right)
    pu.try_pick!
    assert_equal 2, pu.player.boots.size
    assert_nil pu.boot_at(0,1)
    pu.try_pick!
    assert_equal 2, pu.player.boots.size
    assert_nil pu.boot_at(0,1)
    pu.try_drop!()
    assert_nil pu.boot_at(0,1)
    pu.player.next_boots!
    pu.try_drop!()
    assert_not_nil pu.boot_at(0,1)
  end

  def test_boots_cannot_be_dropped_where_there_is_already_something
    pu = PuzzleWithBoots.new
    b1 = Boots.new
    pu.enters_player!
    pu.player.pick!(b1)
    pu.try_move!(:up)
    pu.try_move!(:right)
    pu.player.next_boots!
    assert_equal 2, pu.player.boots.size
    assert pu.player.boots.member?(b1)
    assert_not_nil pu.boot_at(0,1)
    pu.try_drop!
    assert_equal 2, pu.player.boots.size
    assert_not_nil pu.boot_at(0,1)
    assert pu.player.boots.member?(b1)
  end

  def test_boots_can_be_reset
    pu = PuzzleWithBoots.new
    assert_equal DummyBoots, pu.boot_at(0,1).class
    pu.boot 0, 1, nil
    assert_nil pu.boot_at(0,1)
  end

  def test_boots_cannot_be_added_on_non_walkable
    pu = PuzzleWithBoots.new
    pu.set_cell 0,0, Wall.new
    begin
      pu.boot 0,0, DummyBoots
      bad "Should not be possible to put boots on non walkable"
    rescue CellError => e
      assert "Attempt to add cell on non walkable", e.message
    end
  end

  def test_boots_can_be_added_on_entry
    pu = PuzzleWithBoots.new
    i,j = pu.in
    pu.boot i,j, DummyBoots
    assert_equal DummyBoots, pu.boot_at(i,j).class

    i,j = pu.out
    pu.boot i,j, DummyBoots
    assert_equal DummyBoots, pu.boot_at(i,j).class
  end

  def test_non_walkable_cell_cannot_be_placed_on_something_with_boots
    pu = PuzzleWithBoots.new
    assert_not_nil pu.boot_at(0,1)
    begin
      pu.set_cell(0,1,Wall.new)
      bad("Should not be possible to put a non walkable on something that has boots")
    rescue CellError => e
      assert_equal("Attempt to set a non walkable cell at position 0,1 that contains boots", e.message)
    end
  end

  class TestNonExistingNamedCellPuzzle < Puzzle
    dim 3,1
    rows do
      row "I-O"
    end
  end

  def test_defining_event_on_non_existing_named_cell_throws_error
    pu = TestNonExistingNamedCellPuzzle.new
    begin
      pu.story_event :foo do
      end
      bad("No cell named foo, should complain !")
    rescue CellError => e
      assert_equal "There is no cell named foo to define an event", e.message
    end
  end

  class AllreadyCalledEventPuzzle < Puzzle
    dim 3,1
    rows do
      row "I-O"
    end
    named_cells do
      named_cell :foo,0,1
    end
  end

  def test_events_can_be_notified_whether_they_occured_already
    pu = AllreadyCalledEventPuzzle.new
    m = mock()
    pu.story_event :foo do |puzzle, called|
      if (!called)
        m.first_call(puzzle)
      else
        m.second_call(puzzle)
      end
    end
    m.expects(:first_call).with(pu).times(1)
    m.expects(:second_call).with(pu).times(1)
    pu.enters_player!
    pu.try_move!(:right)
    pu.try_move!(:left)
    pu.try_move!(:right)
  end

  def test_events_can_be_notified_how_many_times_they_where_called
    pu = AllreadyCalledEventPuzzle.new
    m = mock()
    pu.story_event :foo do |puzzle, called, count|
      m.event_called(puzzle, called, count)
    end

    m.expects(:event_called).with(pu, false, 0).times(1)
    m.expects(:event_called).with(pu, true, 1).times(1)
    m.expects(:event_called).with(pu, true, 2).times(1)

    pu.enters_player!
    pu.try_move!(:right)
    pu.try_move!(:left)
    pu.try_move!(:right)
    pu.try_move!(:left)
    pu.try_move!(:right)
  end

  def test_several_events_can_occur_on_one_named_cell
    pu = AllreadyCalledEventPuzzle.new
    m = mock()
    pu.story_event :foo do |puzzle, called, count|
      m.first_event_called(puzzle, called, count)
    end
    pu.story_event :foo do |puzzle, called, count|
      m.second_event_called(puzzle, called, count)
    end

    m.expects(:first_event_called).with(pu, false, 0).times(1)
    m.expects(:second_event_called).with(pu, false, 0).times(1)

    pu.enters_player!
    pu.try_move!(:right)
  end

  def test_puzzle_cannot_have_several_cells_with_the_same_name
    pu = Puzzle.empty(3,3)
    pu.named_cell(:foo, 0, 1)
    begin
      pu.named_cell(:foo, 1,1)
      bad("Two cells can't have the same name")
    rescue CellError => e
      assert_equal "Another cell already has this name", e.message
    end
    # However do not complain if this is the same
    pu.named_cell(:foo, 0, 1)
  end

  class MultiCellEventPuzzle < Puzzle
    dim 3,2
    rows do
      row "I--"
      row "--O"
    end
    named_cells do
      named_cell :foo,0,1
      named_cell :bar,1,0
    end
  end

  def test_puzzle_can_have_the_same_event_on_several_cells
    pu = MultiCellEventPuzzle.new
    m = mock()
    m.expects(:event_occured).with(pu, false, 0).times(1)
    m.expects(:event_occured).with(pu, true, 1).times(1)

    pu.story_event [:foo, :bar] do |pu, called, count|
      m.event_occured(pu, called, count)
    end

    pu.enters_player!
    pu.try_move!(:right)
    pu.try_move!(:left)
    pu.try_move!(:down)
  end


end
