require "yaml"

require "level"

class Adventure

  attr_reader :name, :plugins, :levels, :prefix

  def initialize
    @name = nil
    @plugins = []
    @levels = []
    @prefix = ""
    @current_index = -1
  end

  def load!(yaml)
    struct = YAML.load(yaml)

    @name = struct["adventure"]["name"]
    @plugins = struct["adventure"]["plugins"]
    @prefix = struct["adventure"]["prefix"]
    struct["adventure"]["levels"].each do |l|
      levels << Level.new(l["puzzle"], l["name"])
    end
  end

  def save
    adv = { "name" => @name,
      "prefix" => @prefix,
      "plugins" => @plugins,
      "levels" => []
    }

    @levels.each do |l|
      adv["levels"] << {
        "puzzle" => l.puzzle_file,
        "name" => l.puzzle_class_name
      }
    end

    { "adventure" => adv}.to_yaml
  end

  def has_next_level?
    @current_index < (@levels.size-1)
  end

  def next_level!
    @current_index = @current_index + 1
  end

  def current_level
    if (@current_index == -1 || @levels.empty?)
      nil
    else
      @levels[@current_index]
    end
  end

  def load_next_level!
    next_level!
    current_level.load!(@prefix)
  end

  def load_plugins!
    Plugins.need(@plugins)
  end

end
