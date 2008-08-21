require 'plugin_test_case'

class WaterTest < PluginTestCase
  tested_plugin :water

  def test_water_cells_exits
    c = WaterCell.new
    assert !c.walkable?
    assert_equal "~", c.letter
    assert_equal "water/img/water_cell.png", c.src
  end

end
