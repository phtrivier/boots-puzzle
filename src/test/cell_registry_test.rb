
require 'bp_test_case'

# For testing
class WaterCell < Cell
  walkable false
end

class FooCell < Cell
end

class BarCell < Cell
end

class CellRegistryTest < BPTestCase

  def test_cells_can_be_created_and_registerd_quicly

    CellTool.for("water")

    assert_not_nil WaterCellTool
    assert ToolsRegistry.registered_cell_tools.member?(WaterCellTool)

    editor = mock()
    editor.expects(:change_editor_cell).with(0,1,WaterCell)

    t = WaterCellTool.new
    t.act(editor, 0, 1)

  end

  def  test_cell_tools_can_be_passed_the_class_itself

    CellTool.for(FooCell)

    editor = mock()
    editor.expects(:change_editor_cell).with(0,1, FooCell)

    t = FooCellTool.new
    t.act(editor,0,1)

  end

  def test_cell_tools_can_be_passed_extra_behavior

    CellTool.for("bar") do |editor, i , j|
      editor.bing(i,j)
    end

    editor = mock()
    editor.expects(:change_editor_cell).with(0,1, BarCell)
    editor.expects(:bing).with(0,1)

    t = BarCellTool.new
    t.act(editor, 0, 1)

  end


end
