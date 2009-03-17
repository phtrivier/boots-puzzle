class Level3Puzzle < Puzzle
 dim 16,10
 rows do
  row "#######~~#######"
  row "#-#-#-%~~---##-#"
  row "#>#-#--~~---##>#"
  row "#-#-#--~~---##-#"
  row "######I~~-######"
  row "######-~~O######"
  row "#--#-#-~~-##---#"
  row "#%-#-#-~~-##---#"
  row "#--#-#%~~-##---#"
  row "#######~~#######"
 end

 named_cells do
  named_cell :wall_1_1, 1, 2
  named_cell :wall_1_2, 2, 2
  named_cell :wall_1_3, 3, 2
  named_cell :wall_1_4, 6, 2
  named_cell :wall_1_5, 7, 2
  named_cell :wall_1_6, 8, 2
  named_cell :wall_2_1, 1, 5
  named_cell :wall_2_2, 2, 5
  named_cell :wall_2_3, 3, 5
  named_cell :wall_2_4, 6, 5
  named_cell :wall_2_5, 7, 5
  named_cell :wall_2_6, 8, 5
  named_cell :sw_wall1, 1, 6
  named_cell :sw_wall2, 8, 6
  named_cell :wall_4_1, 1, 13
  named_cell :wall_4_2, 2, 13
  named_cell :wall_4_3, 3, 13
  named_cell :wall_3_1, 1, 10
  named_cell :wall_3_2, 2, 10
  named_cell :wall_3_3, 3, 10
  named_cell :wall_3_4, 6, 10
  named_cell :wall_3_5, 7, 10
  named_cell :wall_3_6, 8, 10
  named_cell :wall_4_4, 6, 13
  named_cell :wall_4_5, 7, 13
  named_cell :wall_4_6, 8, 13
  named_cell :wall_5_1, 1, 3
  named_cell :wall_5_2, 2, 3
  named_cell :wall_5_3, 3, 3
  named_cell :wall_5_4, 6, 3
  named_cell :wall_5_5, 7, 3
  named_cell :wall_5_6, 8, 3
  named_cell :tunnel_bottom, 7, 14
  named_cell :tunnel_top, 2, 14
  named_cell :sw_tunnel, 7, 1
  named_cell :tunnel_left, 2, 1
 end

 boots do
  boot 7,4,DoubleBoots
 end


end
