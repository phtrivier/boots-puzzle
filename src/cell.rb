class Cell

  # This might be redefined if needed
  def walkable?
    false
  end

  def self.walkable(b=true)
    self.instance_eval do
      define_method :walkable? do
        return b
      end
    end
  end

  def src
    "img/#{self.class.name.downcase}.png"
  end

  # Make something happen when
  # the player walks in a given cell.
  # @param puzzle (so that funny stuff can happen)
  def walk!(puzzle)
  end

end

class Wall < Cell
end

class Walkable < Cell
  walkable
end

class In < Walkable
end

class Out < Walkable
end
