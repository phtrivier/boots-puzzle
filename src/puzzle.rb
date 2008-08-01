# Boots Puzzle - puzzle.rb
#
# Puzzme class
#
# Copyright (C) 2008 Pierre-Henri Trivier
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA


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
    @named_cells = { }

    init_dimensions

    init_in_out

    if (respond_to?(:init_named_cells))
      init_named_cells
    end

    if (respond_to?(:init_story))
      init_story
    end

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

  def set_cell(i,j,c)
    @cells[i][j] = c
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

  def valid?(i,j)
    i >= 0 and i < @w and j >= 0 and j < @h
  end

  # Initialize the player to the entry of
  # the puzzle
  def enters_player!

    if (@in == [nil,nil])
      raise NoEntry.new("No entry in this puzzle !")
    end

    @player = Player.new
    @player.move!(@in)
  end

  # Try and move the player to another position.
  # The current boots of the player are used
  # to make the move.
  def try_move!(dir)
    @player.current_boots.try_move!(self, dir)
  end

  def self.named_cells(&block)
    self.instance_eval do
      define_method(:init_named_cells, block)
    end
  end

  def cell_by_name(name)
    res = nil
    if (@named_cells.has_key?(name))
      i,j = @named_cells[name]
      res = cell(i,j)
    end
    res
  end

  # Defined a named cell
  def named_cell(name, i, j)
    @named_cells[name] = [i,j]
  end

  # TODO : indicate which story should be loaded
  def self.story(story_name)
    include story_name
  end

  # TODO : define an event
  def story_event(name, base_class, &walk_proc)
    cell = base_class.new

    cell.meta.instance_eval do
      define_method(:walk!) do |puzzle|
        walk_proc.call(puzzle)
      end
    end

    set_cell_by_name(name, cell)
  end

  # Replace a named cell.
  def set_cell_by_name(name, c)
    if (@named_cells.has_key?(name))
      i,j = @named_cells[name]
      @cells[i][j] = c
    else
       raise NoCellError.new("No cell named #{name} in puzzle")
    end
  end

end

