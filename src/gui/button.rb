class Button

  attr_reader :label, :x, :y, :w, :h

  def initialize(label,x,y,w,h, &block)
    @label = label
    @x = x
    @y = y
    @w = w
    @h = h
    @block = block
  end

  def check(event)
    mouse_x = event.x
    mouse_y = event.y
    if (mouse_x > @x and mouse_x < @x + @w and
        mouse_y > @y and mouse_y < @y + @h)
      @block.call
    end
  end
  
end

class ButtonGroup < Array

  def initialize(x, y, w, h, delta)
    @x = x
    @y = y
    @w = w
    @h = h
    @delta = delta
  end

  def add_button(label, &block)
    push Button.new(label, @x, @y, @w, @h, &block)
    @y = @y + @h + @delta
  end

end
