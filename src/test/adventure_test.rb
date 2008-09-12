# Boots Puzzle - adventure_test.rb
#
# Test for the adventure class
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

require "bp_test_case"

require 'adventure.rb'

class AdventureTest < BPTestCase

  def setup
     @str = <<EOF
adventure:
  name: "adv"
  prefix : "levels"
  plugins:
    - "toto"
    - "tata"
    - "titi"
  levels:
    - puzzle: "foo_puzzle"
    - puzzle: "bar_puzzle"
    - puzzle: "baz_puzzle.rb"
      name: "CustomBazPuzzle"
EOF

    @a = Adventure.new

  end

  def test_saves_the_minium
    @a.load!(@str)
    s = @a.save

    assert !s.match("FooPuzzle")
    assert !s.match("BarPuzzle")
    assert s.match("baz_puzzle.rb")
    assert s.match("CustomBazPuzzle")

  end


  def test_loading_adventure

   @a.load!(@str)

    assert_equal "adv", @a.name
    assert_equal 3, @a.plugins.size
    assert_equal 3, @a.levels.size
    assert_equal "levels", @a.prefix
    assert_equal "foo_puzzle", @a.levels[0].puzzle_name
    assert_equal "FooPuzzle", @a.levels[0].puzzle_class_name
    assert_equal "baz_puzzle", @a.levels[2].puzzle_name
    assert_equal "CustomBazPuzzle", @a.levels[2].puzzle_class_name

    @b = Adventure.new
    @b.load!(@a.save)

    assert_equal @a.name, @b.name
    assert_equal @a.plugins, @b.plugins

    (0..2).each do |i|

      al = @a.levels[i]
      bl = @b.levels[i]

      assert_equal al.puzzle_name, bl.puzzle_name
      assert_equal al.puzzle_class_name, bl.puzzle_class_name

    end

  end

  def test_finds_level_by_puzzle_name

    @a.load!(@str)

    l = @a.level_by_name("foo_puzzle")
    assert_not_nil l
    assert_equal "foo_puzzle", l.puzzle_name

    l = @a.level_by_name("foo")
    assert_not_nil l
    assert_equal "foo_puzzle", l.puzzle_name

  end

  def test_iterates_over_level
    @a.load!(@str)

    assert_nil @a.current_level

    assert @a.has_next_level?
    @a.next_level!
    assert_equal "foo_puzzle", @a.current_level.puzzle_name

    assert @a.has_next_level?
    @a.next_level!
    assert_equal "bar_puzzle", @a.current_level.puzzle_name

    assert @a.has_next_level?
    @a.next_level!
    assert_equal "baz_puzzle", @a.current_level.puzzle_name


    assert !@a.has_next_level?
  end

  def test_loads_next_level_with_prefix
    @a = Adventure.new
    @a.load!(@str)

    l = mock()
    l.expects(:load!).with("levels")
    @a.levels[0] = l

    assert @a.has_next_level?
    @a.load_next_level!
  end

  def test_go_to_level_by_name
    @a = Adventure.new
    @a.load!(@str)
    assert @a.has_level_named?("foo")
    assert @a.has_level_named?("bar")
    @a.go_to_level_named!("bar")
    assert_equal "bar_puzzle", @a.current_level.puzzle_name

    begin
      @a.go_to_level_named!("prout")
      bad("Bad level name")
    rescue RuntimeError => e
        assert_equal "No level named like prout", e.message
    end

  end


  def test_adventure_can_be_loaded_with_no_levels_or_plugins
    s = <<EOF
---
adventure:
adventure:
  name: "adv"
  prefix : "levels"
  plugins:
  levels:
EOF
    @a.load!(s)
    assert_equal [], @a.levels
    assert_equal [], @a.plugins

  end

end
