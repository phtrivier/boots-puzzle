# TODO : Find a way to make this shorter
# class WaterCellTool < CellTool.new(WaterCell) ?
# CellTool.tool_for(WaterCell)
class WaterCellTool < CellTool
  def initialize
    super(WaterCell)
  end
end
ToolsRegistry.register_cell_tools(WaterCellTool)
