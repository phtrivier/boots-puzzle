require 'puzzle'

class Story

  def self.name_for(puzzle_name, klass_name = nil)
    klass_name = Puzzle.name_for(puzzle_name) unless klass_name
    "#{klass_name}Story"
  end

  def self.for(puzzle_name, klass_name = nil, &block)

    klass_name = Story.name_for(puzzle_name) unless klass_name

    klass = Module.new

    klass.instance_eval do
      define_method :init_story , block
    end

    Kernel.const_set(klass_name, klass)

  end

end
