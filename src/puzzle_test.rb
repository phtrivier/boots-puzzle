require 'test/unit'

require 'puzzle'

class PuzzleTest < Test::Unit::TestCase

  class NoDimPuzzle < Puzzle

  end

  class DimPuzzle < Puzzle
      dim 4,3
  end

  def test_reads_dimension
    p = DimPuzzle.new
    assert_equal 4, p.w
    assert_equal 3, p.h

    q = NoDimPuzzle.new
    assert_equal nil, q.w
    assert_equal nil, q.h

  end

  class RowsPuzzle < Puzzle
    dim 3,4
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
    assert_equal ExtendedCell, p.cells[0][1].class
  end

  class InvalidCharPuzzle < Puzzle
    dim 1,1
    row "%"
  end

  def test_invalid_cell_definition_with_no_extension_cause_errors
    begin
      p = InvalidCharPuzzle.new
      assert("Should not be possible to create this", false)
    rescue Puzzle::BadCellCharError => e
      assert_equal "%", e.char
    end
  end


end
