class Puzzle

  alias static_old_try_move! try_move!

  attr_reader :last_direction

  def try_move!(dir)
    @last_direction = dir
    static_old_try_move!(dir)
  end

end
