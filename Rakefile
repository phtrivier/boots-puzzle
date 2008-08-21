require 'rake'
require 'rake/testtask'

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
  $LOAD_PATH << "./src/plugins/core"

  # Odly enough, seems like I can't get logging to work in RakeTestTask...
  # TODO : PASS parameter to change the config ?
  log_config("dev")

  require 'play_puzzle'
  play
end

desc "Run the puzzle editor"
task :editor => [:test] do |t|
  puts "Sorry, editor can not be run at the moment (don't know why ...)"
  cmd = "shoes src/editor/editor.rb"
  puts cmd
  cmd2 = "shoes src/editor/editor.rb foo_puzzle.rb FooPuzzle"
  puts cmd2
end

desc "Help"
task :help do
  puts "Boots puzzle (C) Pierre-Henri Trivier - 2008"
  puts "--------------------------------------------"
  puts "To launch the editor :"
  puts " shoes src/editor/editor.rb"
  puts "or"
  puts " shoes src/editor/editor.rb foo_puzzle.rb FooPuzzle"
  puts "---"
  puts "To launch the game :"
  puts " rake play"
  puts "or"
  puts " rake play src/editor/foo_puzzle.rb FooPuzzle"
end

