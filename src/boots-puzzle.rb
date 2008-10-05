#!/usr/bin/env ruby
BP_VERSION="0.3.2"

$LOAD_PATH << "."
$LOAD_PATH << "gui"
$LOAD_PATH << "plugins/core"

ARGV.each do |arg|
  [Regexp.new("--(.*)=(.*)"), Regexp.new("-(.*)=(.*)")].each do |r|
    m = arg.match(r)
    if (m!=nil)
      ENV[m[1]] = m[2]
    end
  end
end

require 'boots-puzzle-wrapper'
wrap_play(".")
