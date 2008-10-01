#!/usr/bin/env ruby
BP_VERSION="0.3.1"

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

def from_env(long, short, default)
  res = default
  if (ENV[long])
    res = ENV[long]
  elsif (ENV[short])
    res = ENV[short]
  end
  res
end

adventure_name = from_env("adventure", "a", "foobar")
level_name = from_env("level", "l", nil)

require "gui"
play(:adventure_name => adventure_name, :level_name => level_name, :prefix => ".")
