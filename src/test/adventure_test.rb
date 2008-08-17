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
      name: "FooPuzzle"
    - puzzle: "bar_puzzle"
      name: "BarPuzzle"
EOF

    @a = Adventure.new

  end

  def test_loading_adventure

   @a.load!(@str)

    assert_equal "adv", @a.name
    assert_equal 3, @a.plugins.size
    assert_equal 2, @a.levels.size
    assert_equal "levels", @a.prefix
    assert_equal "foo_puzzle", @a.levels[0].puzzle_file
    assert_equal "FooPuzzle", @a.levels[0].puzzle_class_name

    @b = Adventure.new
    @b.load!(@a.save)

    assert_equal @a.name, @b.name
    assert_equal @a.plugins, @b.plugins

    (0..1).each do |i|

      al = @a.levels[i]
      bl = @b.levels[i]

      assert_equal al.puzzle_file, bl.puzzle_file
      assert_equal al.puzzle_class_name, bl.puzzle_class_name

    end

  end

  def test_iterates_over_level
    @a.load!(@str)

    assert_nil @a.current_level

    assert @a.has_next_level?
    @a.next_level!
    assert_equal "foo_puzzle", @a.current_level.puzzle_file

    assert @a.has_next_level?
    @a.next_level!
    assert_equal "bar_puzzle", @a.current_level.puzzle_file

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

end
