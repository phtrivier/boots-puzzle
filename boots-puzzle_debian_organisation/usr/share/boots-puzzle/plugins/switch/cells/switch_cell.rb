Cell.for_plugin("switch", :parent => StaticCell) do
  letter "%"
  walkable true
end

# TODO : Define the switch here (do some class definition magic ?)
# Either define self.on / self.off
# That's ruby after all .... I am allowed to write what I want !!

class SwitchCell

  alias switch_old_initialize initialize

  def initialize
    switch_old_initialize
    @on = false
    @setteled = false
  end

  def on?
    @on
  end

  def off?
    !@on
  end

  def force_on!(value)
    @on = value
  end

  def on(&block)
    self.meta.instance_eval do
      define_method :switch_on! do |pu|
        if (!setteled?)
          block.call(pu)
          @on = true
        end
      end
    end
  end

  def off(&block)
    self.meta.instance_eval do
      define_method :switch_off! do |pu|
        if (!setteled?)
          block.call(pu)
          @on = false
        end
      end
    end
  end

  def switch_on!(puzzle)
    # Default callback for on : does nothing
    if (not setteled?)
      @on = true
    end
  end

  def switch_off!(puzzle)
    # Default callback for off : does nothing
    if (not setteled?)
      @on = false
    end
  end

  def static_contact!(puzzle, dir)
    if (@on)
      switch_off!(puzzle)
    else
      switch_on!(puzzle)
    end
  end

  def src
    value = if @on then "on" else "off" end
    "switch/img/switch_#{value}.png"
  end

  def settle!
    @setteled = true
  end

  def setteled?
    @setteled
  end

end
