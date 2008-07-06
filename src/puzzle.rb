require 'cell'
require 'errors'
require 'player'

class Puzzle

  # Ints with the dimension
  attr_accessor :w, :h
  # Two-dimensionnal  array of cells
  attr_accessor :cells
  # Arrays of length two with the position
  # of the entry and exit of the puzzle.
  # TODO : Make sure there is only one in.
  # TODO : Potentially, make several outs ?
  attr_reader :in, :out
  # The player, nul until 'enters_player!' is called
  attr_reader :player

  # Class methods to make definition of a puzzle
  # DSL-like

  # A 'static' array of all cells string
  # provided by 'row'

  # Sets the size of the puzzle.
  # The rows will have to respect those dimensions.
  def self.dim(w,h)
    self.instance_eval do

      define_method(:w) do
        w
      end

      define_method(:h) do
         h
      end
    end
  end

  # Add a row to the puzzle.
  # Argument is a string of characters, each character
  # corresponding to a cell.
  # Following chars are built-in :
  #  I for entry
  #  O for exit
  #  - for a walkable cell
  #  # for a wall
  # Puzzle can define a method 'extend_cell', which creates
  # other type of cells from a single char.
  def self.row(txt)

    self.instance_eval do

      if (!instance_variable_defined?(:@c_cells))
        instance_variable_set(:@c_cells, [])
      end

      @c_cells << txt

    end

  end

  def self.c_cells
    if (!instance_variable_defined?(:@c_cells))
      nil
    else
      instance_variable_get(:@c_cells)
    end
  end

  def self.meta
    class << self
      self
    end
  end

  # Parse a row of cells defined by 'row'
  def parse_row(txt)
    res = []

    if (txt.size != @w)
      raise BadDimension.new("Bad row : #{txt}, expecting #{@w} cell(s)")
    end

    txt.each_byte do |b|
      c = b.chr

      case c
        when "#" then res << Wall.new
        when "I" then res << In.new
        when "O" then res << Out.new
        when "-" then res << Walkable.new
        else
           if (respond_to?(:extend_cell))
              res << extend_cell(c)
           else
             raise BadCellCharError.new(c)
           end
      end
    end

    res
  end

  # Constructor
  def initialize
    @w = w
    @h = h
    @cells = []

    init_dimensions

    init_in_out

  end

  # Init the position of entry and exit
  def init_in_out
    @in = @out = [nil,nil]

    each_cell do |i,j,c|
      if (c.class == In)
        @in = [i,j]
      elsif (c.class == Out)
        @out = [i,j]
      end
    end

  end

  # Init the dimension of the puzzle
  def init_dimensions

    if (self.class.c_cells != nil)
      self.class.c_cells.each do |txt|
        @cells << parse_row(txt)
      end

      if @cells.size != @h
        raise BadDimension.new("Bad puzzle ; found #{@cells.size} row(s), expecting #{h}")
      end
    end

  end

  # A cell by its position
  def cell(i,j)
    @cells[i][j]
  end

  # Iterate over the cells
  # Yields the position of each cell (two ints) and the
  # cell itself
  def each_cell

    @cells.each_with_index do |row, i|
      row.each_with_index do |c, j|
        yield i,j,c
      end
    end

  end

  # Is a given cell walkable ?
  def walkable?(i,j)
    cell(i,j).walkable?
  end

  # Initialize the player to the entry of
  # the puzzle
  def enters_player!

    if (@in == [nil,nil])
      raise NoEntry
    end

    @player = Player.new
    @player.move(@in)
  end

end

