require 'test/unit'

require 'cell'

class CellTest < Test::Unit::TestCase

  class WalkableCell < Cell
    walkable true
  end

  def test_knowns_whether_cell_is_walkable
    assert WalkableCell.new.walkable?
  end

  class NonWalkableCell < Cell
  end

  class NonWalkableCell2 < Cell
    walkable false
  end

  def test_returns_false_by_default
    assert !(NonWalkableCell.new.walkable?)
    assert !(NonWalkableCell2.new.walkable?)
  end

  class WalkableSuggar < Cell
    walkable
  end

  def test_syntactic_suggar_for_walkable
    assert WalkableSuggar.new.walkable?
  end

  class W1 < Cell
  end
  class W2 < Cell
    walkable
  end
  class W3 < Cell
    walkable
  end
  class W4 < W3
    walkable false
  end

  def test_walkable_follow_inheritence
    assert !(W1.new.walkable?)
    assert (W2.new.walkable?)
    assert (W3.new.walkable?)
    assert !(W4.new.walkable?)
  end

  def test_common_cells
    assert Walkable.new.walkable?
    assert In.new.walkable?
    assert Out.new.walkable?
    assert ! Wall.new.walkable?
  end

end
