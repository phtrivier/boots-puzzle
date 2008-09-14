require 'rake'
require 'rake/testtask'
require 'fileutils'
require 'rubygems'
require 'log4r'
require 'log4r/yamlconfigurator'
require 'log4r/outputter/datefileoutputter'

include Log4r

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

desc "Run the game on a sample app"
task :play => [:test] do |t|
  $LOAD_PATH << "./src"
  $LOAD_PATH << "./src/gui"
  $LOAD_PATH << "./src/plugins/core"

  FileUtils.mkdir_p("logs")
  log_config("dev")

  adventure_name = from_env("adventure", "a", "foobar")
  level_name = from_env("level", "l", nil)

  require 'gui'

  play(:adventure_name => adventure_name, :level_name => level_name)
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

desc "Help"
task :help do
  puts "Boots puzzle (C) Pierre-Henri Trivier - 2008"
  puts "--------------------------------------------"
  puts "Puzzle editor :"
  editor_usage(" ")
  puts "---"
  puts "To launch the game (with a default adventure):"
  gui_usage("")
end

