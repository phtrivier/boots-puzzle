require 'test/unit'

require 'puzzle'

class PuzzleTest < Test::Unit::TestCase

  class DimPuzzle < Puzzle
      dim 4,3
  end

  class NoDimPuzzle < Puzzle

  end

  def test_reads_dimension
    p = DimPuzzle.new
    assert_equal 4, p.w
    assert_equal 3, p.h

    q = NoDimPuzzle.new
    assert_equal nil, q.w
    assert_equal nil, q.h

  end



end
