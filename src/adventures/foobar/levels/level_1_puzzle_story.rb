Story.for("level_1_puzzle") do
  tunnel(:tunnel_top, :tunnel_bottom)

  story_event :tunnel_top do |puzzle, called|
    if (!called)
      puzzle.message("Whao, I though I was somewhere else !")
    end
  end

  story_event :entry do |puzzle, called|
    if (!called)
      puzzle.message("Hello, you just entered the FOOBAR maze ...")
    end
  end

  story_event :next_to_entry do |puzzle, called, count|
    case count
      when 0 then puzzle.message("We're gonna have so much fun !!")
      when 1 then puzzle.message("This tunnel is really fun.")
      else puzzle.message("I really like what is happening here.")
    end
  end

end
