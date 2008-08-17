class StagedPuzzle < Puzzle
  dim 2,1
  rows do
    row "IO"
  end
  named_cells do
    named_cell :entry, 1,0
  end
  story StagedPuzzleStory
end
