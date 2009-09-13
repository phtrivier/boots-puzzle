class Level2Puzzle < Puzzle
 dim 8,8
 rows do
  row "########"
  row "#------#"
  row "#-----%#"
  row "#----###"
  row "I----#-O"
  row "#----###"
  row "#-----%#"
  row "########"
 end

 named_cells do
  named_cell :master, 2, 2
  named_cell :switch, 2, 6
  named_cell :door, 4, 5
  named_cell :book1, 6, 1
  named_cell :electric1, 6, 6
 end


end
