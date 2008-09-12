module BlockUtils

  def safe_call_block(block, puzzle, called, count)
    case block.arity
    when 1 then block.call(puzzle)
    when 2 then block.call(puzzle, called)
    else block.call(puzzle, called, count)
    end
  end

end
