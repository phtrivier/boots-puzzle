class Cell
  def swimable?
    false
  end

  def self.swimable(val=true)
    self.instance_eval do
      define_method :swimable? do
         val
      end
    end
  end
end
