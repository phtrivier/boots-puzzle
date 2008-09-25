Story.for("level_3") do

  story_method :toggle_walls do |nbs|
    nbs.each do |i|
      toggle_wall(i)
    end
  end

  story_method :toggle_wall do |wall_nb|
    top_cell = cell_by_name("wall_#{wall_nb}_1")
    if (top_cell.walkable?)
      switch_wall(wall_nb, Wall, Walkable)
    else
      switch_wall(wall_nb, Walkable, Wall)
    end
  end

  story_method :switch_wall do |wall_nb, top_class, bottom_class|
    (1..3).each do |i|
      set_cell_by_name("wall_#{wall_nb}_#{i}", top_class.new)
      set_cell_by_name("wall_#{wall_nb}_#{i+3}", bottom_class.new)
    end
  end

  story_switch :sw_wall1 do
    on do |puzzle|
      puzzle.toggle_walls([1,5])
    end

    off do |puzzle|
      puzzle.toggle_walls([1,5,3])
    end
  end

  story_switch :sw_wall2 do
    on do |puzzle|
      puzzle.toggle_walls([2,5,4])
    end

    off do |puzzle|
      puzzle.toggle_walls([2,4])
    end
  end

  story_switch :sw_tunnel do
    on do |puzzle|
      puzzle.set_cell_by_name(:tunnel_top, Walkable.new)
      puzzle.set_cell_by_name(:tunnel_bottom, TunnelExtremityCell.new)
      puzzle.tunnel(:tunnel_left, :tunnel_bottom)
    end

    off do |puzzle|
      puzzle.set_cell_by_name(:tunnel_top, TunnelExtremityCell.new)
      puzzle.set_cell_by_name(:tunnel_bottom, Walkable.new)
      puzzle.tunnel(:tunnel_left, :tunnel_top)
      puzzle.toggle_wall(2)
    end
  end

end
