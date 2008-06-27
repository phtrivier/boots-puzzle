require 'cell'
require 'errors'

class Puzzle

  attr_accessor :w, :h
  attr_accessor :cells

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

  def self.row(txt)

    self.instance_eval do
      if (@c_cells == nil)
        @c_cells = []
      end
      @c_cells << txt
    end

  end

  def self.c_cells
    @c_cells
  end

  def self.meta
    class << self
      self
    end
  end

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

  def initialize
    @w = w
    @h = h
    @cells = []

    if (self.class.c_cells != nil)
      self.class.c_cells.each do |txt|
        @cells << parse_row(txt)
      end

      if @cells.size != @h
        raise BadDimension.new("Bad puzzle ; found #{@cells.size} row(s), expecting #{h}")
      end

    end

  end

  def cell(i,j)
    @cells[i][j]
  end

end
