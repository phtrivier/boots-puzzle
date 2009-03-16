class Level4Puzzle < Puzzle
 dim 16,10
 rows do
  row "I--##~~-%##---->"
  row "---##~~--##-----"
  row "---##~~--##-----"
  row "---##~~--#######"
  row "---##-~~--######"
  row "---##--~~--##---"
  row "#######-~~-##---"
  row "------#--~~##---"
  row "------#--~~##---"
  row ">-----#--~~##--O"
 end

 named_cells do
  named_cell :tunnel_left, 9, 0
  named_cell :sw, 0, 8
  named_cell :tunnel_right_top, 0, 15
  named_cell :tunnel_right_bottom, 5, 15
  named_cell :chess_line_1, 0, 1
  named_cell :chess_line_2, 1, 0
 end

 boots do
  boot 3,2,DoubleBoots
  boot 7,2,KnightLeftBoots
 end

 quote :author => "(anonyme)",
 :text => "\"Les ech\303\250cs ? Je pr\303\251f\303\250re les victoires\""
end
