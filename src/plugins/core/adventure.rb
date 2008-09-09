# Boots Puzzle - adventure.rb
#
# An adventure (a collection of levels)
#
# Copyright (C) 2008 Pierre-Henri Trivier
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA

require "yaml"

require "level"

class Adventure

  attr_reader :name, :plugins, :levels, :prefix

  def initialize(name=nil)
    @name = name
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

      if (l.follows_conventions?)
        adv["levels"] << {
          "puzzle" => l.puzzle_name
        }
      else
        adv["levels"] << {
          "puzzle" => l.puzzle_file,
          "name" => l.puzzle_class_name
        }
      end

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
    load_current_level!
  end

  def load_current_level!
    current_level.load!(@prefix)
  end

  def load_plugins!
    Plugins.need(@plugins)
  end

  def level_by_name(str)

    @levels.find do |level|
      level.named_like?(str)
    end

  end

  def has_level_named?(str)
    level_by_name(str) != nil
  end

  def go_to_level_named!(str)
    l = level_by_name(str)
    if (l==nil)
      raise RuntimeError.new("No level named like #{str}")
    else
      @current_index = @levels.index(l)
    end
  end

end
