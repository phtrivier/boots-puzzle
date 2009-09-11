class Puzzle

  attr_accessor :current_chatter

  def chat(txt)
    message("#{@current_chatter[:name]} says : #{txt}")
  end

  def chatter(cell_name, chatter_name, &block)

    existing_cell = cell_by_name(cell_name)

    chat_cell = ChatCell.new
    chat_cell.block = block
    chat_cell.background_cell = existing_cell
    # TODO : properly handle the case where no chatter has
    # been declared
    chat_cell.chatter = Chat.find_chatter(chatter_name)
    
    set_cell_by_name(cell_name, chat_cell)

  end

end
