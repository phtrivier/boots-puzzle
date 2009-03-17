class Level2Puzzle < Puzzle
 dim 16,10
 rows do
  row "########~#######"
  row "#I----%#~----->#"
  row "#------#~------#"
  row "#------#~~~~~~~~"
  row "########~~~~~~~~"
  row "#-----##------O#"
  row "#-----##########"
  row "#-----##########"
  row "#>----##-------#"
  row "################"
 end

 named_cells do
  named_cell :sw, 1, 6
  named_cell :tunnel_left, 8, 1
  named_cell :tunnel_bottom, 8, 14
  named_cell :tunnel_top, 1, 14
  named_cell :entry_1, 1,2
  named_cell :entry_2, 2,1
 end

 boots do
  boot 8,8,Palms
  boot 3,1,DoubleBoots
 end

 quote :text => "Only stupid people never change their minds, that's what I have always said !"
end
