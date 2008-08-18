class Puzzle

  def tunnel(i,o)

    story_event i, TunnelExtremityCell do |puzzle|
#      puts "Walked on IN #{i}"
      puzzle.player.move! puzzle.cell_position_by_name(o)
    end

    story_event o, TunnelExtremityCell do |puzzle|
#      puts "Walked on OUT #{o}"
      puzzle.player.move! puzzle.cell_position_by_name(i)
    end

  end

end
