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

  attr_reader :adventure, :puzzle
  

  def initialize(prefix, adventure_roots)
    @prefix = prefix
    @adventure_roots = adventure_roots
    @loaded_adventure_folder = nil
    @adventure = nil
    @puzzle = nil
  end

  def manifest_plugins!(root, adventure_name)
    # Take into account the plugins
    # declared internally by the adventure
    Plugins.add_root("#{root}/#{adventure_name}/plugins")
    Plugins.read_manifests!
  end

  def load_adventure!(adventure_name)
    @adventure_name = adventure_name
    @adventure = nil
    # Init the system-wide plugins repository
    Plugins.init("#{@prefix}/plugins")
    @adventure_roots.each do |root|
      puts "Trying to load adventure from #{root} ; Adventure is present ? #{has_adventure?(root, adventure_name)}"
      if (has_adventure?(root, adventure_name))
        @loaded_adventure_folder = "#{root}/#{adventure_name}"
        @levels_folder = levels_folder(@adventure_name)
        puts "loaded_adventure_forlder : #{@loaded_adventure_folder}"
        @adventure = Adventure.new(root)
        puts "Manifesting plugins with root #{root} and adventure name #{adventure_name}"
        manifest_plugins!(root, adventure_name)
        @adventure_file_name = "#{@loaded_adventure_folder}/adventure.yml"
        @adventure.load!(File.open(@adventure_file_name))
        @adventure.load_plugins!
        break
      end
    end
    @adventure
  end

  def has_adventure?(root, name)
    File.exists?("#{root}/#{name}/adventure.yml")
  end

  def load!(adventure_name)
    @adventure = nil
    adventure_root = default_adventure_root(adventure_name)
    begin
      @adventure = load_adventure!(adventure_name)
      if (adventure == nil)
        raise Exception.new("No adventure found (we looked in #{@adventure_roots.join(",")})")
      end
    rescue Exception => e
      puts "Unable to open adventure #{adventure_name} : #{e}"
      exit
    end
    @adventure
  end

  def default_adventure_root(adventure_name)
    "#{@prefix}/adventures/#{adventure_name}"
  end

  def levels_folder(adventure_name)
    @levels_folder = "#{@loaded_adventure_folder}/levels"
  end

  # Save the current adventure
  def save_adventure
    # We should save the puzzle and the adventure now
    puts "About to create adventure file #{@adventure_file_name}"
    File.open(@adventure_file_name, "w") << @adventure.save
  end

  # Add a level in the currently loaded adventure.
  # The adventure file is saved, a new puzzle file is created with the proper name.
  # This sets the 'level' and 'puzzle' attribute to the newly created
  # level and puzzle.
  def add_level(puzzle_name, w, h)
    @level = Level.new(puzzle_name)
    @puzzle_name = @level.puzzle_name
    @puzzle = Puzzle.empty(w,h)
    @adventure.levels << @level
    # Save the adventure now
    save_adventure
    # Save the puzzle now
    # TODO : Move this to adventure_loader
    @file_name = "#{@levels_folder}/" + @level.puzzle_file
    @puzzle_class = @level.puzzle_class_name
    save_puzzle
  end

  # Save the currently loaded puzzle
  # Note : for the moment it works only with a newly created puzzle, this should be fixed
  def save_puzzle
    # TODO : Make this work 
    res = @puzzle.serialize(@puzzle_class)

    if (!File.exists?(@levels_folder))
      FileUtils.mkdir_p(@levels_folder)
    end

    File.open(@file_name, "w+") do |f|
      f << res
    end
  end

  def load_level(puzzle_name)
    # This assumes that the loaded adventure has the level
    # TODO : shout if not
    @level = @adventure.level_by_name(puzzle_name)
    # The level can be loaded and the puzzle initialized
    @level.load!(@levels_folder, false)
    @puzzle_name = @level.puzzle_name
    @puzzle = @level.puzzle
    @file_name = "#{@levels_folder}/" + @level.puzzle_file
    @puzzle_class = @level.puzzle_class_name
  end

end
