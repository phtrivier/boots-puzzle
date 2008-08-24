require 'bp_test_case'

require 'puzzle'

class StoryTest < BPTestCase

  @@called = false

  Story.for("foo_puzzle") do
    story_event :foo, Walkable do |puzzle|
      @@called = true
    end
  end

  class FooPuzzle < Puzzle
    dim 3,1
    rows do
      row "I-O"
    end

    named_cells do
      named_cell :foo, 0,1
    end

  end

  def test_story_created_from_short_def
    assert_not_nil FooPuzzleStory
    assert !@@called, "the story event should not have been called yet"

    pu = FooPuzzle.new
    pu.init_story_from_module FooPuzzleStory

    pu.enters_player!
    pu.try_move!(:right)
    assert @@called, "the story event should have been called"
  end

end
