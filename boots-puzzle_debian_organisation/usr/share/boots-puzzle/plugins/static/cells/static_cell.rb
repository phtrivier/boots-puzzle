class StaticCell < Walkable
  walkable true

  def walk!(puzzle)
    # Call all events, and move
    super(puzzle)
    # Move back
#    puts "Calling contact with #{puzzle.last_direction}"
    static_contact!(puzzle, puzzle.last_direction)
#    puts "Going back to original cell"
    puzzle.try_move!(Directions.reverse(puzzle.last_direction))
  end

  # Method to control what happens when you walk on a
  # static cell.
  # params : puzzle
  # params : direction of the player when moving on this
  def static_contact!(puzzle, dir)
    "to be overriden by subclasses"
  end

  # Class method to make it possible to
  # define the contact method
  # in Cell.for_plugin
  def self.static_contact(&block)
    self.instance_eval do
      define_method :static_contact!, block
    end
  end

end
