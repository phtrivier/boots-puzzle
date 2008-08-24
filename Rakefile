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

  t.libs << ["./src/test", "./src/plugins/core"]
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

desc "Run the game on a sample app"
task :play => [:test] do |t|
  $LOAD_PATH << "./src"
  $LOAD_PATH << "./src/gui"
  $LOAD_PATH << "./src/plugins/core"

  # Odly enough, seems like I can't get logging to work in RakeTestTask...
  # TODO : PASS parameter to change the config ?
  FileUtils.mkdir_p("logs")
  log_config("dev")

  require 'gui'
  play
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

desc "Help"
task :help do
  puts "Boots puzzle (C) Pierre-Henri Trivier - 2008"
  puts "--------------------------------------------"
  puts "Puzzle editor :"
  editor_usage(" ")
  puts "---"
  puts "To launch the game :"
  puts " rake play"
  puts "or"
  puts " rake play src/editor/foo_puzzle.rb FooPuzzle"
end

