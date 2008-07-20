class Player
  attr_reader :i,:j

  def pos
    [@i, @j]
  end

  def move(pos)
    @i,@j = pos
  end

end
