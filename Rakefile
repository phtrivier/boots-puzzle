require 'rake'
require 'rake/testtask'

task :default => [:test]

desc "Run basic tests"
Rake::TestTask.new("test") do |t|
  t.libs << ["./src/test", "./src/core"]
  t.pattern = 'src/test/*_test.rb'
  t.verbose = true
  t.warning = true
end

desc "Run the game on a sample app"
task :play => [:test] do |t|
  $LOAD_PATH << "./src"
  $LOAD_PATH << "./src/core"
  require 'play_puzzle'
  play
end
