# TODO : Make it easier to declare and register cell ...
# (guess the image name, give only the reachable stuff, etc...
# Register the cell by itself
class Palms < BareFeet

  def reachable?(puzzle, i,j)
    super(puzzle,i,j) || puzzle.cell(i,j).swimable?
  end

  def src
    "water/img/palms.png"
  end

  def txt
    "palms"
  end

end
