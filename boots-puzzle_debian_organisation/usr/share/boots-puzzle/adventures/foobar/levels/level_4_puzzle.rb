class Level4Puzzle < Puzzle
 dim 16,10
 rows do
  row "############---~"
  row "#---##---------~"
  row "#--##----------~"
  row "#--#-----------~"
  row "#---I-------#-~~"
  row "#-------O--##~~-"
  row "#---------##~~--"
  row "#---~~#####~~---"
  row "#---~~~~~~~~~---"
  row "#---~~-~~~------"
 end

 named_cells do
  named_cell :toto, 6, 3
 end

 boots do
  boot 4,6,DoubleBoots
  boot 2,10,Palms
  boot 9,6,Palms
  boot 2,9,Palms
  boot 5,6,DoubleBoots
  boot 6,6,DoubleBoots
  boot 2,11,Palms
 end


end
