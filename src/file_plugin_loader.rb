# Boots Puzzle - file_plugin_loader.rb
#
# Plugin Loader using files and directories
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

require 'puzzle'

class FilePluginLoader

  def initialize(root)
    @root = root
  end

  def plugin_dir(name)
    "#{@root}/#{name}"
  end

  def plugin_elem_dir(name, elem)
    "#{plugin_dir(name)}/#{elem}"
  end

  def has_element?(name, elem)
    !plugin_element_filenames(name, elem).empty?
  end

  def plugin_element_filenames(name, elem)
    Dir["#{plugin_elem_dir(name, elem)}/*.rb"]
  end

  def load_element(name, elem)
    plugin_element_filenames(name, elem).each do |filename|
      require filename
    end
  end

end
