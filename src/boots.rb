class Boots

  def try_move!(puzzle, dir)
    ni,nj = new_position(puzzle, dir)
    try_move_to( puzzle, ni,nj)
  end

  def new_position(puzzle, dir)
    raise RuntimeError.new("Should not instanciate Boots and call new_position. Subclass instead")
  end

  def try_move_to(puzzle, i,j)
    if (puzzle.valid?(i,j) and puzzle.walkable?(i,j))
      puzzle.player.move!([i,j])
    end
  end

end


# Default boots for the player,
# which walks one cell at a time.
class BareFeet < Boots

  def new_position( puzzle, dir)
    i,j = puzzle.player.pos
    case dir
      when :up then [i-1, j]
      when :down then [i+1, j]
      when :left then [i, j-1]
      when :right then [i, j+1]
    end
  end

end
