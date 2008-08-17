# Boots Puzzle - plugins.rb
#
# Globally accessible interface to a plugin manager
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

require 'plugin_manager'
require 'file_plugin_loader'

# TO BE TESTED
class Plugins

  def self.init(root = "plugins")
    @@root = root
    @@manager = PluginManager.new(FilePluginLoader.new(@@root))
  end

  def self.manifested?(name)
    @@manager.manifested?(name)
  end

  def self.loaded?(name)
    @@manager.loaded?(name)
  end

  def self.manifest(name, deps = [])
    @@manager.manifest!(name, deps)
  end

  # Declare that you need plugins to be loaded
  # args : a list (or an array) of plugin names
  def self.need(*args)
    if (args != nil)

      names = nil
      if (args[0].class == Array)
        names = args[0]
      else
        names = args
      end

      names.each  do |name|
        if (!@@manager.loaded?(name))
          @@manager.load!(name)
        end
      end
    end
  end

  def self.read_manifests()
    Dir["#{@@root}/*/manifest.rb"].each do |filename|
      # Manifests are reloaded each time (usefull for tests)
      load filename
    end
  end

end
