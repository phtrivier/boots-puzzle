class Puzzle

  def story_once(naming, &block)
    story_event naming do |pu, called, count|
      if (!called)
        safe_call_block(block, pu, called, count)
      end
    end
  end

  alias :story_once_for_all  :story_once

end
