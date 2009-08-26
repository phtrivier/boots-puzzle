Story.for("level_0") do

  story_once [:entry_up, :entry_left,
              :entry_bottom, :entry_right] do |pu|
    pu.message("Hi !\nThis is a demo for Boots Puzzle. Your goal is to reach the exit (in green). Notice there are boots over there ...\nGood luck!")
  end

  story_event :hole do |pu|

    if (pu.player.boots.size == 1)
      pu.message("Try and take the double boots over there...")
    else
      pu.message("Try to use double boots (use SPC to toogle)")
    end

  end

  story_once :past_hole do |pu|
    pu.message "Cool, you passed the wall ! Now run for the exit..."
  end

end
