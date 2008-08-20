# Boots Puzzle - level_test.rb
#
# Tests for the level class
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
require 'level'

class LevelTest < BPTestCase

  def test_level_without_story
    l = Level.new("no_story_puzzle","NoStoryPuzzle")
    l.load!("testdir/level_test")
    assert_not_nil(l.puzzle)
    assert_equal NoStoryPuzzle, l.puzzle.class
  end

  def test_level_without_story_without_puzzle_name
    l = Level.new("no_story_puzzle")
    l.load!("testdir/level_test")
    assert_not_nil(l.puzzle)
    assert_equal NoStoryPuzzle, l.puzzle.class
  end

  def test_level_with_story
    l = Level.new("staged_puzzle","StagedPuzzle")
    l.load!("testdir/level_test")
    assert_not_nil(l.puzzle)
    assert_equal StagedPuzzle, l.puzzle.class
    assert StagedPuzzleStory::Loaded
  end

  def test_level_with_story_without_puzzle_name
    l = Level.new("staged_puzzle")
    l.load!("testdir/level_test")
    assert_not_nil(l.puzzle)
    assert_equal StagedPuzzle, l.puzzle.class
    assert StagedPuzzleStory::Loaded
  end

  # TODO : if the name is 'toto.rb', check the story i 'toto_story.rb' ... be nice !

  def test_level_is_finished_or_not
    l = Level.new("staged_puzzle","StagedPuzzle")
    l.load!("testdir/level_test")
    l.puzzle.enters_player!
    assert !l.finished?
    l.puzzle.try_move!(:right)
    assert l.finished?
  end

end
