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
