class ChatCell < StaticCell

  attr_accessor :chatter
  attr_accessor :chat_count
  attr_writer :block
  attr_writer :background_cell

  def initialize()
    super
    @chat_count = 0
  end

  def static_contact!(puzzle, dir)
    if (@block != nil) 
      @chat_count = @chat_count + 1
      puzzle.current_chatter = @chatter
      @block.call(puzzle, @chat_count)
    end
  end

  def src
    res = nil
    if (@background_cell != nil)
      if (@background_cell.src.is_a? Array)
        res = @background_cell.src
        res << @chatter[:sprite]
      else
        res = [@background_cell.src, @chatter[:sprite]]
      end
    else
      res = @chatter[:sprite]
    end
    res
  end

end
