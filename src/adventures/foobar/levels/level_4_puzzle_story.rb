Story.for("level_4") do

  chatter :chatter1, :bob do |puzzle, count|
    if (count == 1) 
      puzzle.chat "Hi, how are you ?"
    elsif (count == 2) 
      puzzle.chat "I think I have already talked to you, haven\'t I ?"
    else
      puzzle.chat "Bogger off, now, please..."
    end	 
  end

  chatter :chatter2, :alice do |puzzle, count|
    puzzle.chat "Oh my god, they killed Kenny !!"
  end


end
