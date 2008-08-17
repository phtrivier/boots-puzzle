require "yaml"

class Adventure

  attr_reader :name, :plugins, :levels

  def initialize
    @name = nil
    @plugins = []
    @levels = []
  end

  def load!(yaml)

    struct = YAML.load(yaml)

    @name = struct["adventure"]["name"]
    @plugins = struct["adventure"]["plugins"]
    struct["adventure"]["levels"].each do |l|
      levels << Level.new(l["puzzle"], l["name"])
    end

  end

  def save

    adv = { "name" => @name,
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


end
