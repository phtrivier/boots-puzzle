# Boots Puzzle - plugin_manager.rb
#
# Plugin Manager
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

require 'plugin'

class PluginManager

  def meta
    class << self
      self
    end
  end

  attr_accessor :loader

  def initialize(loader = nil)
    @plugins = { }
    @loading = []
    @loader = loader
  end

  def manifest!(name, dependencies = [])
    if (manifested?(name))
      raise PluginError.new("Attempt to manifest plugin #{name} twice")
    end
    p = Plugin.new(name, dependencies)
    @plugins[name] = p
    p.status = :manifested
  end

  def loaded?(name)
    exists_with_status(name, :loaded)
  end

  def manifested?(name)
    exists_with_status(name, :manifested)
  end

  def exists_with_status(name, st)
    p = @plugins[name]
    (p!=nil and p.status == st)
  end

  def load!(name)

    # Do not load an already loaded one
    if (loaded?(name))
      return
    end

    # Do not load a plugin that we are already loading
    if (@loading.member?(name))
      raise PluginError.new("Can not load plugin #{@loading[0]} because of circular dependencies : #{@loading.join(' -> ')} -> #{@loading[0]}.")
    end

    # Do not attempt to load an unmanifested one
    if (!manifested?(name))
      raise PluginError.new("Attempt to load unmanifested plugin #{name}")
    end


    # Remenber that we are trygin to load this plugin
    @loading << name

    to_load = @plugins[name]

    to_load.status = :loading

    # Load dependencies
    to_load.dependencies.each do |dep|
      if (!loaded?(dep))
        load!(dep)
      end
    end

    # Load elements
    load_plugin_elements(to_load)

    to_load.status = :loaded

    @loading.delete(name)
  end

  def load_plugin_elements(plugin)
    #puts "Loading plugin's element #{plugin.name}"
    if (@loader != nil)
      name = plugin.name
      Plugin::ElementTypes.each do |type|
        #puts "Checking with loader : #{@loader}, type : #{type} on plugin #{name}"
        if (@loader.has_element?(name, type))
          @loader.load_element(name, type)
        end
      end
    end
  end

end
