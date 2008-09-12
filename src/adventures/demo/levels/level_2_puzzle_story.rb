Story.for("level_2") do
   story_event [:entry_up, :entry_left, :entry_bottom, :entry_right] do |pu, called|
     if (!called)
       pu.message("This is a demo for Boots Puzzle. \n Your goal is to reach the exit (in green). \nGood luck!")
     end
   end
end
