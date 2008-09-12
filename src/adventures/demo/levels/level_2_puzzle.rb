class Level2Puzzle < Puzzle
 dim 16,10
 rows do
  row "################"
  row "#------##------#"
  row "#------##------#"
  row "#------##------#"
  row "#-I----##-----O#"
  row "#------##------#"
  row "#-------#------#"
  row "#------##------#"
  row "#------##------#"
  row "################"
 end

 named_cells do
  named_cell :entry_up, 3, 2
  named_cell :entry_right, 4, 3
  named_cell :entry_bottom, 5, 2
  named_cell :entry_left, 4, 1
  named_cell :hole_in_wall, 6, 7
 end

 boots do
  boot 4,6,DoubleBoots
 end
end
