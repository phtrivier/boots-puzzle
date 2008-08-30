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
require 'story'

require 'rubygems'
require 'dictionary'

require 'naming'
require 'name'

class Puzzle

  include Naming

  # Ints with the dimension
  attr_accessor :w, :h
  # Two-dimensionnal  array of cells
  attr_accessor :cells
  attr_reader :named_cells

  # The player, nil until 'enters_player!' is called
  attr_reader :player

  # Meta class accessor
  def self.meta
    class << self
      self
    end
  end

  # Class methods to make definition of a puzzle
  # DSL-like
  # ----
  # Rows management

  # Sets the size of the puzzle.
  # The rows will have to respect those dimensions.
  def self.dim(w,h)
    self.instance_eval do
      define_method :init_dimensions do
        @w = w
        @h = h
      end
    end
  end

  def self.rows(&block)
    self.instance_eval do
      define_method "init_rows", block
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
  def row(txt)
    @cells << parse_row(txt)
  end

  # Parse a row of cells defined by 'row'
  def parse_row(txt)
    res = []

    if (txt.size != @w)
      raise BadDimension.new("Bad row : #{txt}, expecting #{@w} cell(s)")
    end

    txt.each_byte do |b|
      c = b.chr

      klass = Cell.type_by_letter(c)
      if (klass != nil)
        res << klass.new
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

  # ------------------------------
  # Initers registers themselves using 'initer :name'.
  # Then in the end of the constructor, a method 'init_#{name}' will
  # be called if available
  @@initers = []

  def self.initer(name)
    @@initers << name
  end

  def call_initers
    @@initers.each do |name|
      initer_method_name = "init_#{name}"
      if (respond_to?(initer_method_name))
        send initer_method_name
      end
    end
  end

  # -------------------------------
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
    @named_cells = Dictionary.new
    @boots = { }

    call_initers

    check_dimensions

  end

  # Order is important
  # If dim has been called on the class, init_dimensions
  # will initialize @h and @w
  initer(:dimensions)
  initer(:rows)

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
#   def init_dimensions

#     if (@empty_puzzle)
#       @h.times do |i|
#         @cells[i] = []
#       end
#     else
#       if @cells.size != @h
#         raise BadDimension.new("Bad puzzle ; found #{@cells.size} row(s), expecting #{h}")
#       end
#     end

#   end

  # NOTE : THIS IS THE DEFAULT ONE
  def init_dimensions
    @h.times do |i|
      @cells[i] = []
    end
  end

  def check_dimensions
    if @cells.size != @h
      raise BadDimension.new("Bad puzzle ; found #{@cells.size} row(s), expecting #{h}")
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

  # Set a cell of the puzzle
  def set_cell(i,j,c)
    check_duplicate_in_out(i,j,c)
    check_boots_on_non_walkable(i,j,c)
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

  # ---
  # All puzzles class should have a 'init_named_cells' called if possible)
  initer(:named_cells)

  # Wrapper for the method to declare named_cells
  def self.named_cells(&block)
    self.instance_eval do
      define_method(:init_named_cells, block)
    end
  end

  # Define a named cell (should be called in
  # a block passed to 'named_cells').
  def named_cell(name, i, j)
    @named_cells[name] = [i,j]
  end

  # Retrive a cell by its name.
  # nil if there is no cell with the given name.
  def cell_by_name(name)
    res = nil
    if (@named_cells.has_key?(name))
      i,j = @named_cells[name]
      res = cell(i,j)
    end
    res
  end

  # Get the position of a cell by its name
  def cell_position_by_name(name)
    res = nil
    if (@named_cells.has_key?(name))
      res = @named_cells[name]
    end
    res
  end

  # Replace a named cell.
  def set_cell_by_name(name, c)
    if (@named_cells.has_key?(name))
#      puts "Named cells : #{@named_cells.inspect}"
#      puts "Named cells[#{name}] : #{@named_cells[name].inspect}"
      i,j = @named_cells[name]
#      puts "#{i}, #{j}"
      set_cell(i,j,c)
    else
       raise NoCellError.new("No cell named #{name} in puzzle")
    end
  end

  # Undefine a named cell
  # Throws an error if no cell exists with this name
  def unname_cell(name)

    if (@named_cells.has_key?(name))
      @named_cells.delete(name)
    else
      raise NoCellError.new("No cell named #{name} in puzzle")
    end

  end

  def metaclass
    class << self
      self
    end
  end

  # ---
  # Story

  def init_story_from_module(mod)
    self.class.instance_eval do
      include mod
    end
    # The method should have been defined by
    # the module we just included
    init_story
  end

  # Define an event on a named cell
  # (Note that the base class might actually be
  # in the Puzzle class rather than
  # in the Story module ... anyway ...)
  def story_event(name, base_class=nil, &walk_proc)

    cell = nil
    if (base_class == nil)
      cell = cell_by_name(name)
      if (cell == nil)
        raise CellError.new("There is no cell named #{name} to define an event")
      end
    else
      cell = base_class.new
    end

    cell.meta.instance_eval do
      define_method(:walk!) do |puzzle|
        walk_proc.call(puzzle)
      end
    end

    set_cell_by_name(name, cell)
  end


  # --------------------------------

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

  # Serialze a puzzle
  def serialize(class_name)

    res = "class #{class_name} < Puzzle\n"
    res << " dim #{@w},#{@h}\n"

    res << " rows do\n"
    @cells.each do |line|
      res << "  row \""
      line.each do |c|

        l = Cell.letter_by_type(c.class)
        if (l==nil)
          raise CellError.new("Don't know how to serialize #{c} (type : #{c.class})")
        else
          res << l
        end

      end
      res << "\"\n"
    end
    res << " end\n"

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

  # Try and load a puzzle from a file
  # file_name : rb file to load
  # klass_name : puzzle class (optionnal, standard name will be used if omitted)
  # error_block : what to do if an error happens. The error block is passed
  #  the file name, class name, and the actual error.
  def self.load(str, klass_name = nil, &error_block)
    puzzle = nil
    name = nil
    begin
      name = Name.new(str, { :puzzle_class_name => klass_name})
      require name.puzzle_file_name
      puzzle = Kernel.const_get(name.puzzle_class_name).new
    rescue LoadError, NameError => e
      if block_given? and name != nil
        error_block.call(name.puzzle_file_name, name.puzzle_class_name, e)
      else
        raise e
      end
    end
    puzzle
  end

  # ------------------------------------
  # 'init_boots' should be called if possible
  initer(:boots)

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

  # Get the boot at a given position.
  # nil if there is none.
  def boot_at(i,j)
    @boots[ [i,j] ]
  end

  # Is there a boot at a given position ?
  def boot_at?(i,j)
    boot_at(i,j) != nil
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

