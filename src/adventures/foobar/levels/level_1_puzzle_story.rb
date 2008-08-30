Story.for("level_1_puzzle") do
  tunnel(:tunnel_top, :tunnel_bottom)

  story_event :entry do |puzzle|
    puzzle.message("Hello, you just entered the FOOBAR maze ...")
  end

  story_event :next_to_entry do |puzzle|
    puzzle.message("We're gonna have so much fun !!")
  end

end
