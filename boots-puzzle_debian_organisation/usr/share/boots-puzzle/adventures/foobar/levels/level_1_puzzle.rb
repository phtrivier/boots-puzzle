class Level1Puzzle < Puzzle
 dim 4,4
 rows do
  row "I-->"
  row "#~~#"
  row ">-#O"
  row "--%-"
 end

 named_cells do
  named_cell :entry, 0, 1
  named_cell :next_to_entry, 0, 2
  named_cell :tunnel_top, 0, 3
  named_cell :tunnel_bottom, 2, 0
  named_cell :sw, 3, 2
  named_cell :wall1, 2,2
 end

 boots do
  boot 0,2,DoubleBoots
  boot 0,1,Palms
 end
end
