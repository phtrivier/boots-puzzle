Story.for("level_0") do

  story_once [:entry_up, :entry_left,
              :entry_bottom, :entry_right] do |pu|

    pu.message("This is a demo for Boots Puzzle. \n Your goal is to reach the exit (in green). \nGood luck!")

  end

  story_event :hole do |pu|

    if (pu.player.boots.size == 1)
      pu.message("Try and take the double boots over there... (use SPC)")
    else
      pu.message("Try to use double boots (use TAB to toogle)")
    end

  end

  story_event :past_hole do |pu|
    pu.message "Cool, you passed the wall ! Now run for the exit..."
  end

end
