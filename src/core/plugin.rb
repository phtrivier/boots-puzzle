# Boots Puzzle - plugin.rb
#
# Plugin
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

class Plugin

  ElementTypes = [:patches, :cells, :boots, :stories, :tools]

  attr_reader :name
  attr_accessor :status
  attr_reader :dependencies

  def initialize(name, dependencies)
    @name = name
    @dependencies = dependencies
    @status = :unmanifested
  end

  # Sloppyness forgiving error message
  def self.manifest(name)
    raise RuntimeError.new("Manifest syntax error for plugin #{name} : use Plugins.manifest (with an 's') instead of Plugin.manifest in #{name}/manifest.rb.")
  end

end

class PluginError < RuntimeError
end
