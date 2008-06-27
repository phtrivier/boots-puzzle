class Puzzle

  attr_accessor :w, :h

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

  def initialize
    @w = self.w
    @h = self.h
  end

end
