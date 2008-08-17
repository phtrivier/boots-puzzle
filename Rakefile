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
