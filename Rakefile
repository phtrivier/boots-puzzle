require 'rake'
require 'rake/testtask'
require 'fileutils'
require 'rubygems'
require 'log4r'
require 'log4r/yamlconfigurator'
require 'log4r/outputter/datefileoutputter'

include Log4r

# .list file for Debian
List = "boots-puzzle.list"

def log_config(conf)
  cfg = YamlConfigurator
  cfg.load_yaml_file("./conf/#{conf}/log4r.yml")
end

task :default => [:test]

desc "Run all tests (core and plugin)"
task :test => [:core_test, :plugins_test]

desc "Run core tests"
Rake::TestTask.new("core_test") do |t|

  t.libs << ["./src/test", "./src/plugins/core", "./src/gui"]
  t.pattern = 'src/test/*_test.rb'
  t.verbose = false
  t.warning = false

end

desc "Run plugins tests"
Rake::TestTask.new("plugins_test") do |t|
  t.libs << ["./src/test", "./src/test/plugins/**/*", "./src/plugins/core", "./src/plugins/**/*"]
  t.pattern = "src/test/plugins/**/*_test.rb"
  t.verbose = false
  t.warning = false
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

def play_adventure(adventure_name, level_name)
  $LOAD_PATH << "./src"
  $LOAD_PATH << "./src/gui"
  $LOAD_PATH << "./src/plugins/core"

  FileUtils.mkdir_p("logs")
  log_config("dev")

  require 'gui'

  play(:adventure_name => adventure_name, :level_name => level_name, :prefix => "src")
end

desc "Run an adventure"
task :play => [:test] do |t|

  adventure_name = from_env("adventure", "a", "foobar")
  level_name = from_env("level", "l", nil)

  play_adventure(adventure_name, level_name)
end

desc "Run the demo adventure"
task :demo do
  play_adventure("demo", "level_0")
end

desc "Run the puzzle editor"
task :editor => [:test] do |t|
  puts "--------------------------------"
  puts "Sorry, editor can not be run at the moment (don't know why ...)"
  editor_usage("")
end

def editor_usage(offset)
  cmd2 = "Usage : shoes src/editor/editor.rb ADVENTURE_NAME [PUZZLE_NAME]"
  puts offset + cmd2
  ex = "Example : shoes src/editor/editor.rb foobar level_1"
  puts offset + ex
end

def gui_usage(offset)
  puts offset + "Usage : rake play [adventure|a=ADVENTURE_NAME] [level|l=LEVEL_NAME]"
  puts offset + "Example : rake play adventure=foobar l=level_1"
end

def puts_with_offset(offset, lines)
  lines.each do |line|
    puts offset + line
  end
end

def controls(offset)
  puts_with_offset(offset+"- ",["Use arrow keys to move",
                               "Use Space to pick boots on the ground",
                               "Use Tab to change the boots you're wearing",
                               "Use Ctrl to drop the boots you're wearing",
                               "Use h to display a quick help reminder",
                               "Use j to display a hint of where you can go"])
end

desc "Help"
task :help do
  puts "---------------------------------------------------"
  puts "Boots puzzle (C) Pierre-Henri Trivier - 2008"
  puts "This is free software ; see COPYING for details."
  puts "There is NO WARRANTY (but then, that's only a game)"
  puts "---------------------------------------------------"
  puts "To launch the game (with a default adventure):"
  gui_usage(" ")
  puts "---"
  puts "Default controls : "
  controls(" ")
  puts "---"
  puts "Puzzle editor :"
  editor_usage(" ")
end

desc "Remove emacs backup files"
task :clean do
  Dir["**/*~"].each do |filename|
    FileUtils.rm(filename)
  end
  Dir["logs/*"].each do |filename|
    FileUtils.rm(filename)
  end
  FileUtils.rm_rf("pkg")
  FileUtils.rm_rf("doc/dist")
  FileUtils.rm_rf("linux-2.6-intel")
  FileUtils.rm_rf(List)
end

# Packaging

# Version should be in a file called, ahem .. VERSION
BP_VERSION = File.open("VERSION").read.strip

desc "Display current version"
task :version do
  puts "Boots Puzzle v#{BP_VERSION} - Copyright (C) 2008 Pierre-Henri Trivier"
end

desc "Builds documentation"
task :doc do
  script = <<EOF
cd doc
mkdir dist
texi2pdf -c boots-puzzle.texinfo -o dist/boots-puzzle.pdf
makeinfo boots-puzzle.texinfo --html -o dist/boots-puzzle.html
cd dist
tar -cvf boots-puzzle.html.tar boots-puzzle.html
gzip boots-puzzle.html.tar
cd ../../
EOF
  system(script)
end

# Packaging task are created automagically
require 'rake/packagetask'
Rake::PackageTask.new('boots-puzzle', BP_VERSION) do |p|
  p.need_tar_gz = true
  ["README", "INSTALL", "COPYING", "ART", "ChangeLog", "RELEASES", "Rakefile", "LICENSE", "VERSION"].each do |f|
    p.package_files.include(f)
  end

  p.package_files.include("src/**/*")
  p.package_files.include("conf/**/*")
  p.package_files.include("org/*")
  p.package_files.include("doc/*")
  p.package_files.include("logs/*")
end

# ----------------
# Debian packaging

task :set_version do
  system("sed -e 's/BP_VERSION=.*/BP_VERSION=\"#{BP_VERSION}\"/g' -i src/boots-puzzle.rb")
end

task :deblist do
  $LOAD_PATH << "."
  # This will make what is needed in the script variable
  require 'boots-puzzle_list.rb'
  f = File.open(List, "w")
  f << Script
  f.close
end

desc "Create a debian package using epm"
task :deb => [:clean, :set_version, :test, :doc, :deblist] do
  system("epm -f deb boots-puzzle")
end

