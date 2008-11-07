# Boots Puzzle - adventure_loader.rb
#
# Helper class to load an adventure and all its plugins
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
require "plugins"
require "adventure"

class AdventureLoader
  def initialize(prefix, adventure_roots)
    @prefix = prefix
    @adventure_roots = adventure_roots
    @loaded_adventure_folder = nil
  end

  def manifest_plugins!(root, adventure_name)
    # Take into account the plugins
    # declared internally by the adventure
    Plugins.add_root("#{root}/#{adventure_name}/plugins")
    Plugins.read_manifests!
  end

  # TODO : Maje this works
  def load_adventure!(adventure_name)
    adventure = nil
    # Init the system-wide plugins repository
    Plugins.init("#{@prefix}/plugins")

    @adventure_roots.each do |root|
      #puts "Trying to load adventure from #{root} ; Adventure is present ? #{has_adventure?(root, adventure_name)}"
      if (has_adventure?(root, adventure_name))
        @loaded_adventure_folder = "#{root}/#{adventure_name}"
        adventure = Adventure.new(root)
        manifest_plugins!(root, adventure_name)
        adventure.load!(File.open("#{@loaded_adventure_folder}/adventure.yml"))
        adventure.load_plugins!
        break
      end
    end

    adventure
  end

  def has_adventure?(root, name)
    File.exists?("#{root}/#{name}/adventure.yml")
  end

  def load!(adventure_name)
    adventure = nil
    adventure_root = default_adventure_root(adventure_name)
    begin
      adventure = load_adventure!(adventure_name)
      if (adventure == nil)
        raise Exception.new("No adventure found (we looked in #{@adventure_roots.join(",")})")
      end
    rescue Exception => e
      puts "Unable to open adventure #{adventure_name} : #{e}"
      exit
    end
    adventure
  end

  def default_adventure_root(adventure_name)
    "#{@prefix}/adventures/#{adventure_name}"
  end

  def levels_folder(adventure_name)
    @levels_folder = "#{@loaded_adventure_folder}/levels"
  end

end
