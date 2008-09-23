Story.for("level_2") do

  tunnel(:tunnel_left, :tunnel_top)

  story_switch :sw do

    on do |puzzle|
      puzzle.set_cell_by_name(:tunnel_top, Walkable.new)
      puzzle.set_cell_by_name(:tunnel_bottom, TunnelExtremityCell.new)
      puzzle.tunnel(:tunnel_left, :tunnel_bottom)
    end

    off do |puzzle|
      puzzle.set_cell_by_name(:tunnel_bottom, Walkable.new)
      puzzle.set_cell_by_name(:tunnel_top, TunnelExtremityCell.new)
      puzzle.tunnel(:tunnel_left, :tunnel_top)
    end

  end

end
