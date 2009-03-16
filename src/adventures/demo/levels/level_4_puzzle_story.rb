Story.for("level_4") do

  story_event [:chess_line_1, :chess_line_2] do |puzzle|
    puzzle.message "Have you ever played Chess ? Do you know the game where you need to reach some point by moving like a Knight ?"
  end

  tunnel :tunnel_left, :tunnel_right_top

  # TODO : Make this a pluggin "switch_tunnels", since I reused it in 
  # more than one level :P
  story_switch :sw do

    on do |puzzle|
      puzzle.set_cell_by_name(:tunnel_right_top, Walkable.new)
      puzzle.set_cell_by_name(:tunnel_right_bottom, TunnelExtremityCell.new)
      puzzle.tunnel(:tunnel_left, :tunnel_right_bottom)
    end

    off do |puzzle|
      puzzle.set_cell_by_name(:tunnel_right_bottom, Walkable.new)
      puzzle.set_cell_by_name(:tunnel_right_top, TunnelExtremityCell.new)
      puzzle.tunnel(:tunnel_left, :tunnel_top)
    end

  end

end
