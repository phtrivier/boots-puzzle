class ChatCell < StaticCell

  attr_accessor :chatter
  attr_accessor :chat_count
  attr_writer :block

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
    @chatter[:sprite]
  end

end
