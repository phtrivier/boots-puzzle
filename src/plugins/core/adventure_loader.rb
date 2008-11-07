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
  def initialize(prefix)
    @prefix = prefix
  end

  def load!(adventure_name)
    adventure_root = adventure_root(adventure_name)
    adventure = Adventure.new
    begin
      # TODO(pht) Make it possible to use the current folder as a root
      # (better yet, use file_loader to load adventures ... and an adventure_loader
      # to do the job !!

      # Init the plugin system
      Plugins.init("#{@prefix}/plugins")
      Plugins.add_root("#{adventure_root}/plugins")
      Plugins.read_manifests!

      # TODO(pht) : Provide file loaders ?
      adventure.load!(File.open("#{adventure_root}/adventure.yml"))
    rescue Exception => e
      puts "Unable to open adventure #{adventure_name} : #{e}"
      exit
    end
    adventure.load_plugins!
    adventure
  end

  def adventure_root(adventure_name)
    "#{@prefix}/adventures/#{adventure_name}"
  end

  def levels_folder(adventure_name)
    @levels_folder = "#{adventure_root(adventure_name)}/levels"
  end

end
