class Level1Puzzle < Puzzle
 dim 16,10
 rows do
  row "################"
  row "#I-----##----->#"
  row "#------##------#"
  row "################"
  row "#------~~~~~~~~~"
  row "#------~~~~~~~~~"
  row "#------~~------#"
  row "#------~~------#"
  row "#>-----~~-----O#"
  row "#######~~#######"
 end

 named_cells do
  named_cell :tunnel_bottom, 8, 1
  named_cell :tunnel_top, 1, 14
 end

 boots do
  boot 2,6,DoubleBoots
  boot 1,9,Palms
 end

 quote :author => "Pen of Chaos",
 :text => "A l'aventure compagnon\nJe suis partis vers l'horizon..."
end
