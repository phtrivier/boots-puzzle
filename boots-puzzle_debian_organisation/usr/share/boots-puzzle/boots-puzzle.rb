#!/usr/bin/env ruby
BP_VERSION="0.3.6"

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

def puts_usage(offset)
  puts_with_offset(offset, "Usage : boots-puzzle [OPTIONS]")
end

def puts_options(offset)
  puts_with_offset(offset, ["--adventure=<ADVENTURE_NAME>  Run an adventure (default to foobar)",
                            "-a=<ADVENTURE_NAME>           (Synonym for --adventure)",
                            "--level=<LEVEL_NAME>          Start at a given level",
                            "-l=<LEVEL_NAME>               (Synonym for --level",
                            "--root=<PATH>                 Provide the location in which adventure folder is given (must be an absolute path)",
                            "-r=<PATH>                     (Synonym for -r",
                            "--help | -h                   Display with help",
                            "--version | -v                Display version number"
                           ])
end

def puts_help
  puts_copy_header
  puts ""
  puts "Usage :"
  puts_usage(" ")
  puts ""
  puts "Options : "
  puts_options(" ")
  puts ""
  puts "Default controls : "
  puts_controls(" ")
end

require 'boots-puzzle-wrapper'
if (has_arg?("help", "h"))
  puts_help
elsif (has_arg?("version", "v"))
  puts_version
else
  wrap_play(File.expand_path("."))
end

