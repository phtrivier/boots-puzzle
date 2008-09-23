Story.for("level_1") do
  tunnel :tunnel_bottom, :tunnel_top

  story_once [:entry_1, :entry_2] do |puzzle|
    puzzle.message("This level demonstrates tunnels, and palms.\nThere is a tunnel entry behind the wall ; try walking on it !")
  end

  story_event :on_palms do |puzzle|
    puzzle.message("With palms on, you can walk on water as if it was the ground. This should help you reach the exit...")
  end

  story_once :water1 do |puzzle|
    puzzle.message("Brilliant, you're walking on water ! Now don't let it go to you head or anything ...")
  end

end
