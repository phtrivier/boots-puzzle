class Level4Puzzle < Puzzle
 dim 21,14
 rows do
  row "#######--------------"
  row "#-----###############"
  row "#-I---#-------------#"
  row "#-----#----~~~~~----#"
  row "#-----#--------~----#"
  row "#-----#--------~----#"
  row "#--------------~----#"
  row "#----~~~~~-----~----#"
  row "#-O------------~----#"
  row "#--------------~-##-#"
  row "#--------------~--#-#"
  row "#--------------~--###"
  row "#--------------~~~~~#"
  row "#####################"
 end

 named_cells do
  named_cell :chatter1, 4, 4
  named_cell :chatter2, 9, 4
 end


end
