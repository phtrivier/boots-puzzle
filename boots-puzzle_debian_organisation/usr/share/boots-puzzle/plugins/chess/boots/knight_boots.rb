class KnightLeftBoots < Boots

  txt "Chess Knight Boots (Left side)"

  def new_position( puzzle, dir)
    i,j = puzzle.player.pos
    case dir
      when :up then [i-2, j-1]
      when :down then [i+2, j+1]
      when :left then [i+1, j-2]
      when :right then [i-1, j+2]
    end
  end

  def src
    "core/img/knight_left_boots.png"
  end

end

class KnightRightBoots < Boots

  txt "Chess Knight Boots (Right side)"

  def new_position( puzzle, dir)
    i,j = puzzle.player.pos
    case dir
      when :up then [i-2, j-1]
      when :down then [i+2, j+1]
      when :left then [i+1, j-2]
      when :right then [i-1, j+2]
    end
  end

  def src
    "core/img/knight_left_boots.png"
  end

end

# TODO : Find images, check the usage of the boots
