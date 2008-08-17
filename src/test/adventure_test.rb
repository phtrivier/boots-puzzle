require "bp_test_case"

require 'adventure.rb'

class AdventureTest < BPTestCase

  def test_loading_adventure

    str = <<EOF
adventure:
  name: "adv"
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
    @a.load!(str)

    assert_equal "adv", @a.name
    assert_equal 3, @a.plugins.size
    assert_equal 2, @a.levels.size
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

end
