require 'rake'
require 'rake/testtask'

task :default => [:test]

desc "Run basic tests"
Rake::TestTask.new("test") do |t|
  t.libs << ["./src/test", "./src/plugins/core"]
  t.pattern = 'src/test/*_test.rb'
  t.verbose = true
  t.warning = true
end

desc "Run the game on a sample app"
task :play => [:test] do |t|
  $LOAD_PATH << "./src"
  $LOAD_PATH << "./src/plugins/core"
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

