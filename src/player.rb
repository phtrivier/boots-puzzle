require 'boots'

class Player
  attr_reader :i,:j
  attr_accessor :current_boots

  def initialize
    @current_boots = BareFeet.new
  end

  def pos
    [@i, @j]
  end

  def move!(pos)
    @i,@j = pos
  end


end
