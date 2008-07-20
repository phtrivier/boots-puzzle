require 'boots'

class Player
  attr_reader :i,:j
  attr_accessor :current_boots

  def initialize
    @current_boots = BareFeet.new
    @boots = { :right => nil, :left => nil }
  end

  def boots_in_right_hand
    @boots[:right]
  end

  def boots_in_left_hand
    @boots[:left]
  end

  def free_hand?
    @boots[:right] == nil || @boots[:left] == nil
  end

  def pos
    [@i, @j]
  end

  def move!(pos)
    @i,@j = pos
  end

  def pick!(boots)
    if (!free_hand?)
      raise RuntimeError.new("No free hand to pick boots")
    end
    if (@boots[:right] == nil)
      @boots[:right] = boots
    elsif (@boots[:left] == nil)
      @boots[:left] = boots
    end
  end

  # TODO : boots should be droped somewhere ;)
  def drop!(side)
    if (side == :right)
      @boots[:right] = nil
    elsif (side == :left)
      @boots[:left] = nil
    else
      raise RuntimeError.new("Wrong side to drop : #{side}")
    end
  end

  def put_on!(side)
    if (bare_feet?)
      @current_boots = @boots[side]
      @boots[side] = nil
    else
      swap_current_with_hand(side)
    end
  end

  def swap_current_with_hand(side)
      tmp = @current_boots
      @current_boots = @boots[side]
      @boots[side] = tmp
  end

  # Put the current boots off, and pick
  # them in any free hand.
  # If no hand is free, the current pair of boots
  # is swapped with the on in right hand.
  def put_off!
    if (@boots[:right] == nil)
      @boots[:right] = @current_boots
      @current_boots = BareFeet.new
    elsif (@boots[:left] == nil)
      @boots[:left] = @current_boots
      @current_boots = BareFeet.new
    else
      # By default, exchange with the right side
      swap_current_with_hand(:right)
    end

  end

  # Is the player walking on bare feet ?
  def bare_feet?
    @current_boots.class == BareFeet
  end
end
