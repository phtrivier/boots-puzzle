class Level0Puzzle < Puzzle
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
  named_cell :past_hole, 6, 9
  named_cell :hole, 6, 7
 end

 boots do
  boot 4,6,DoubleBoots
 end
 quote :author => "J\303\252rome Bonaldi",
 :text => "Man, I swear, it worked during the demo !"
end
