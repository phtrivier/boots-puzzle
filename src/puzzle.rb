# Boots Puzzle - puzzle.rb
#
# Puzzle class
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
  attr_reader :named_cells

  # The player, nul until 'enters_player!' is called
  attr_reader :player

  # Class methods to make definition of a puzzle
  # DSL-like

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
      # TODO : OOfy this ...
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

  # Constructor without argument
  # Dimensions are provided by the parent class,
  # provided 'dim' has been called on them
  def initialize(_w = nil, _h = nil)

    if (_w != nil and _h != nil)
      @w = _w
      @h = _h
    else
      @w = w
      @h = h
    end

    @cells = []
    @named_cells = { }
    @boots = { }

    init_dimensions

    if (respond_to?(:init_named_cells))
      init_named_cells
    end

    if (respond_to?(:init_story))
      init_story
    end

    if (respond_to?(:init_boots))
      init_boots
    end
  end

  # TODO : MAKE SURE THAT SETTING AN IN / OUT TWICE RAISES AN ERROR
  # 'Manual' accessor for in and out
  def in
     find_cell_by_type(In)
  end

  def out
    find_cell_by_type(Out)
  end

  def find_cell_by_type(type)
    res = [nil, nil]
    each_cell do |i,j,c|
      if (c.class == type)
        res = [i,j]
        break
      end
    end
    res
  end

  # Init the dimension of the puzzle
  def init_dimensions

    # If a parent class exists with the description,
    # use it to build the puzzle.
    if (self.class.c_cells != nil)
      self.class.c_cells.each do |txt|
        @cells << parse_row(txt)
      end

      if @cells.size != @h
        raise BadDimension.new("Bad puzzle ; found #{@cells.size} row(s), expecting #{h}")
      end

    else

      # Let the array have proper dimensions no matter what
      # (usefull for Puzzle.empty)
      @h.times do |i|
        @cells[i] = []
      end
    end

  end

  # A cell by its position
  def cell(i,j)
    @cells[i][j]
  end

  def check_duplicate_in_out(i,j,c)
    check_duplicate_extremity(i,j,c, In, self.in, "Attempt to add a duplicate entry")
    check_duplicate_extremity(i,j,c, Out, self.out, "Attempt to add a duplicate exit")
  end

  def check_duplicate_extremity(i,j,c, klass, ext, msg)
    if (c.class == klass)
      if (ext != [nil, nil] and [i,j] != ext)
        raise ExitError.new(msg)
      end
    end
  end

  def check_boots_on_non_walkable(i,j,c)
    if (!c.walkable? and boot_at?(i,j))
      raise CellError.new("Attempt to set a non walkable cell at position #{i},#{j} that contains boots")
    end
  end

  def set_cell(i,j,c)
    check_duplicate_in_out(i,j,c)
    check_boots_on_non_walkable(i,j,c)
    @cells[i][j] = c
  end

  def boot_at?(i,j)
    boot_at(i,j) != nil
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
    i >= 0 and i < @h and j >= 0 and j < @w
  end

  # Initialize the player to the entry of
  # the puzzle
  def enters_player!

    if (self.in == [nil,nil])
      raise NoEntry.new("No entry in this puzzle !")
    end

    @player = Player.new
    @player.move!(self.in)
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

  # Undefine a named cell
  # Throws an error if no cell exists with this name
  def unname_cell(name)
    @named_cells.delete(name) do |not_found_name|
      raise NoCellError.new("No cell named #{not_found_name} in puzzle")
    end
  end

  # Indicate which story should be loaded
  def self.story(story_name)
    include story_name
  end

  # Define an event on a named cell
  # (Note that the base class might actually be
  # in the Puzzle class rather than
  # in the Story module ... anyway ...)
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
      set_cell(i,j,c)
    else
       raise NoCellError.new("No cell named #{name} in puzzle")
    end
  end

  # Convinient method to create an empty puzzle
  def self.empty(w,h)
    pu = Puzzle.new(w, h)
    pu.h.times do |i|
      pu.w.times do |j|
        pu.set_cell(i,j, Walkable.new)
      end
    end
    pu
  end

  def serialize(class_name)

    res = "class #{class_name} < Puzzle\n"
    res << " dim #{@w},#{@h}\n"

    # TODO : Really, make this more extensible, OO and all
    # It must be easy to add code in the Cell class to do
    # the output for me ... without breaking a lot ...
    @cells.each do |line|
      res << " row \""
      line.each do |c|
        if (c.class == Wall)
          res << "#"
        end
        if (c.class == Walkable)
          res << "-"
        end
        if (c.class == In)
          res << "I"
        end
        if (c.class == Out)
          res << "O"
        end
      end
      res << "\"\n"
    end

    if (!@named_cells.empty?)
      res << "\n"
      res << " named_cells do\n"
      @named_cells.each do |name, pos|
        sym = name.to_sym.inspect
        res << "  named_cell #{sym}, #{pos[0]}, #{pos[1]}\n"
      end
      res << " end\n"
    end

    if (!@boots.empty?)
      res << "\n"
      res << " boots do\n"
      @boots.each do |pos, boot|
        res << "  boot #{pos[0]},#{pos[1]},#{boot.class}\n"
      end
      res << " end\n"
    end

    res << "end\n"
    res
  end

  def self.load(file_name, klass_name, &error_block)
     begin
       require file_name
       @puzzle = Kernel.const_get(klass_name).new
     rescue LoadError, NameError => e
       error_block.call(file_name, klass_name, e)
     end
  end

  def boot(i,j,klass)
    new_boots = nil
    if (klass != nil)
      if (not cell(i,j).walkable?)
        raise CellError.new("Attempt to add cell on non walkable")
      end
      new_boots = klass.new
    end
    @boots[ [i,j] ] = new_boots
  end

  def boot_at(i,j)
    @boots[ [i,j] ]
  end

  def remove_boot(i,j)
    @boots.delete( [i,j] ) do |key|
      raise NoBootError.new("No boots at position #{i[0]},#{i[1]}")
    end
  end

  def self.boots(&block)
    self.instance_eval do
      define_method(:init_boots, block)
    end
  end

  def try_pick!
    if (@player.can_pick_boots?)
      i,j = @player.pos
      b = boot_at(i,j)
      if (b != nil)
        @player.pick!(b)
        remove_boot(i,j)
      end
    end
  end

  def try_drop!()
    if (not @player.bare_feet?)
      i,j = @player.pos
      # Only drop if there is nothing on the ground
      if (boot_at(i,j) == nil)
        # Have the player drop the boot, than put it back
        # on the maze
        b = @player.current_boots
        @player.drop!
        boot(i,j, b.class)
      end
    end
  end
end

