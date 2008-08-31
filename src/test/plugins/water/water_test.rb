require 'plugin_test_case'

class WaterTest < PluginTestCase
  tested_plugin :water

  def test_water_cells_exits
    c = WaterCell.new
    assert !c.walkable?
    assert_equal "~", c.letter
    assert_equal "water/img/water_cell.png", c.src
  end

  class RiverPuzzle < Puzzle
    dim 4,1
    rows do
      row "I-~O"
    end
    boots do
      boot 0,1,Palms
    end
  end

  def test_water_cells_are_reachible_by_palms
    p = Palms.new
    pu = RiverPuzzle.new
    assert !pu.cell(0,1).swimable?
    assert pu.cell(0,2).swimable?
    assert p.reachable?(pu, 0, 2)
    pu.enters_player!
    pu.try_move!(:right)
    pu.try_move!(:right)
    # You cannot move with your bare feets
    assert_equal 1, pu.player.pos[1]
    # Take palms, and it should work !
    pu.try_pick!
    pu.player.next_boots!
    pu.try_move!(:right)
    assert_equal 2, pu.player.pos[1]
  end

end
