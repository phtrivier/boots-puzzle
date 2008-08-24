class Level4Puzzle < Puzzle
 dim 16,10
 rows do
  row "################"
  row "#I--~~~~~~~~---#"
  row "#---~------~---#"
  row "#---~------~---#"
  row "#---~------~---#"
  row "#---~------~---#"
  row "#---~------~---#"
  row "#---~------~---#"
  row "#---~------~--O#"
  row "####~######~####"
 end

 boots do
  boot 8,1,DoubleBoots
 end
end
