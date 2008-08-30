class Level1Puzzle < Puzzle
 dim 4,3
 rows do
  row "I-->"
  row "#~~#"
  row ">--O"
 end

 named_cells do
  named_cell :entry, 0,1
  named_cell :next_to_entry, 0, 2
  named_cell :tunnel_top, 0, 3
  named_cell :tunnel_bottom, 2, 0
 end

 boots do
  boot 0,2,DoubleBoots
 end
end
