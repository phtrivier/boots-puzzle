class Puzzle

  # Decorate an existing cell with a decoration
  # cell
  def decorate_cell(cell_name, decoration_cell_type)

    existing_cell = cell_by_name(cell_name)
    decoration_cell = BaseDecorationCell.new(decoration_cell_type)
    decoration_cell.background_cell = existing_cell
    set_cell_by_name(cell_name, decoration_cell)

  end

end
