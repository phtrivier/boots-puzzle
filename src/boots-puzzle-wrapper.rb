# Boots Puzzle - boots-puzzle-wrapper.rb
#
# Command line wrapper
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

# Extract command line argument (in short or long form), with a
# default value
def from_env(long, short, default)
  res = default
  if (ENV[long])
    res = ENV[long]
  elsif (ENV[short])
    res = ENV[short]
  end
  res
end

# Play
# Prefix : folder where sources should be
def wrap_play(prefix)
  adventure_name = from_env("adventure", "a", "foobar")
  level_name = from_env("level", "l", nil)
  play_adventure(adventure_name, level_name, prefix)
end

def play_adventure(adventure_name, level_name, prefix)
  require 'gui'
  play(:adventure_name => adventure_name, :level_name => level_name, :prefix => prefix)
end

# ----------------------
def puts_copy_header
  puts "---------------------------------------------------"
  puts "Boots puzzle (C) Pierre-Henri Trivier - 2008"
  puts "This is free software ; see COPYING for details."
  puts "There is NO WARRANTY (but then, that's only a game)"
  puts "---------------------------------------------------"
end

def puts_with_offset(offset, lines)
  lines.each do |line|
    puts offset + line
  end
end

def puts_controls(offset)
  puts_with_offset(offset+"- ",["Use arrow keys to move",
                               "Use Space to pick boots on the ground",
                               "Use Tab to change the boots you're wearing",
                               "Use Ctrl to drop the boots you're wearing",
                               "Use h to display a quick help reminder",
                               "Use j to display a hint of where you can go"])
end

def puts_version
  puts "Boots Puzzle v#{BP_VERSION} - Copyright (C) 2008 Pierre-Henri Trivier"
end

def has_arg?(long, short)
  ARGV.member?("--#{long}") || ARGV.member?("-#{short}")
end
