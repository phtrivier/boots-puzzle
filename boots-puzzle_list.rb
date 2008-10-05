# This script is used to generates a boots-puzzle.list to be used by rake deb
#

header = <<HERE
# This file should have been generated with 'rake deblist'
# Copyright (C) Pierre-Henri Trivier

%product boots-puzzle
%copyright 2008 by Pierre-Henri Trivier
%vendor Pierre-Henri Trivier
%description Extendible puzzle game
%version #{BP_VERSION}
%readme README
%license LICENSE
%requires ruby
%requires ruby1.8
%requires ruby1.8-dev
%requires libsdl-ruby1.8
%requires libmocha-ruby1.8
%requires rake

# Bin script
f 755 root sys /usr/bin/boots-puzzle bin/boots-puzzle

# Ruby main script
f 755 root sys /usr/share/boots-puzzle/boots-puzzle.rb src/boots-puzzle.rb
f 755 root sys /usr/share/boots-puzzle/boots-puzzle-wrapper.rb src/boots-puzzle-wrapper.rb

HERE

# Uses mkepmlist to generate list of files for debian packaging
def generate(type, folder, out)
  res = ""
  res << "# ---------------\n"
  res << "# #{type} (generated)\n"
  res << `mkepmlist -u root -g sys --prefix /usr/share/boots-puzzle/#{out} #{folder}`
  res << "\n"
end

# TODO : Separate "demo" and "foobar"
script = header
script << generate("Adventures", "src/adventures","adventures")
script << generate("Plugins", "src/plugins", "plugins")
script << generate("Gui", "src/gui", "gui")
script << generate("Documentation", "doc/dist", "doc")
Script = script
