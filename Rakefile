require 'rake'
require 'rake/testtask'
require 'fileutils'
require 'rubygems'

# .list file for Debian
List = "boots-puzzle.list"

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

desc "Run an adventure"
task :play => [:test] do |t|

  $LOAD_PATH << "./src"
  $LOAD_PATH << "./src/gui"
  $LOAD_PATH << "./src/plugins/core"

  require 'boots-puzzle-wrapper'
  wrap_play("src")

end

desc "Run the demo adventure"
task :demo do

  $LOAD_PATH << "./src"
  $LOAD_PATH << "./src/gui"
  $LOAD_PATH << "./src/plugins/core"

  require 'boots-puzzle-wrapper'
  play_adventure("demo", "level_0", "src")

end

desc "Run the puzzle editor"
task :editor => [:test] do |t|
  puts "--------------------------------"
  puts "Sorry, editor can not be run at the moment (don't know why ...)"
  editor_usage("")
end

def puts_editor_usage(offset)
  cmd2 = "Usage : shoes src/editor/editor.rb ADVENTURE_NAME [PUZZLE_NAME]"
  puts offset + cmd2
  ex = "Example : shoes src/editor/editor.rb foobar level_1"
  puts offset + ex
end

def puts_rake_usage(offset)
  puts offset + "Usage : rake play [adventure|a=ADVENTURE_NAME] [level|l=LEVEL_NAME]"
  puts offset + "Example : rake play adventure=foobar l=level_1"
end

desc "Help"
task :help do
  $LOAD_PATH << "src"
  require 'boots-puzzle-wrapper'
  puts_copy_header
  puts "To launch the game (with a default adventure):"
  puts_rake_usage(" ")
  puts "---"
  puts "Default controls : "
  puts_controls(" ")
  puts "---"
  puts "Puzzle editor :"
  puts_editor_usage(" ")
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
  $LOAD_PATH << "src"
  require 'boots-puzzle-wrapper'
  puts_version
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

desc "Set up an apt-repository with the sources"
task :apt => [:deb] do
  FileUtils.rm_rf("apt")
  FileUtils.mkdir_p("apt/binary")
  FileUtils.mkdir_p("apt/sources")
  Dir["linux-2.6-intel/*.deb"].each do |file|
    FileUtils.cp(file, "apt/binary")
  end

  script = <<HERE
cd apt
dpkg-scanpackages binary /dev/null | gzip -9c > binary/Packages.gz
dpkg-scansources sources /dev/null | gzip -9c > sources/Sources.gz
HERE
  system(script)

  release_content = <<HERE
Archive: unstable
Component: contrib
Origin: Pierre-Henri Trivier
Label: boots-puzzle-apt
Architecture: i386
HERE

  File.open("apt/Release", "w") do |f|
    f << release_content
  end

end

desc "Releases all artefacts for a new version"
task :release => [:apt, :package]
