class Level0Puzzle < Puzzle
 dim 6,7
 rows do
  row "--#--#"
  row "-##--#"
  row "##---#"
  row "I----O"
  row "##---#"
  row "-##--#"
  row "--#--#"
 end

 named_cells do
  named_cell :book1, 2, 2
  named_cell :book2, 6, 4
  named_cell :book3, 5, 3
  named_cell :scroll1, 1, 4
 end


end
