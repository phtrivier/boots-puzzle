class Puzzle

  def story_switch(name, opts = {}, &block)

    c = cell_by_name(name)
    if (!c.is_a? SwitchCell)
      raise CellError.new("There is no switch at cell named #{name}")
    end

    if (opts[:start] != nil)
        c.force_on!((opts[:start] == :on))
    end

    c.instance_eval(&block)

  end

end
