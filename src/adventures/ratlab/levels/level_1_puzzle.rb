class Level1Puzzle < Puzzle
 dim 8,8
 rows do
  row "#--#---#"
  row "#--#---#"
  row "#--#---O"
  row "I--#---#"
  row "#-->--->"
  row "#--#---#"
  row "#--#---#"
  row "#--#---#"
 end

 named_cells do
  named_cell :master, 3, 2
  named_cell :tunnel_left, 4, 3
  named_cell :tunnel_right, 4, 7
  named_cell :book1, 6, 1
  named_cell :scroll1, 0, 4
  named_cell :book2, 3, 5
  named_cell :mirror, 5, 6
  named_cell :tunnel_out, 4, 6
 end


end
