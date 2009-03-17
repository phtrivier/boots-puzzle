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

  story_once [:entry_1, :entry_2] do |puzzle|
    puzzle.message "The big thing over there is a switch.\nIf you walk on it, interesting stuff might happen!"
  end

  story_once :sw do |puzzle|
    puzzle.message "Look, magic happening !"
  end

end
