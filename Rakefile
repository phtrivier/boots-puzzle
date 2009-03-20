require 'rake'
require 'rake/testtask'
require 'fileutils'
require 'templates/templates'

# .list file for Debian
List = "boots-puzzle.list"

# ----------------
# Running 

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
  wrap_play(File.expand_path("./src"))
end

desc "Run the puzzle editor"
task :editor do 
  $LOAD_PATH << "./src"
  $LOAD_PATH << "./src/editor"
  $LOAD_PATH << "./src/plugins/core"
  require 'boots-puzzle-wrapper'
  wrap_editor
end

desc "Run the demo adventure"
task :demo do
  $LOAD_PATH << "./src"
  $LOAD_PATH << "./src/gui"
  $LOAD_PATH << "./src/plugins/core"
  require 'boots-puzzle-wrapper'
  play_adventure("demo", "level_0", "src", ["src/adventures"])
end

# -----------
# Usage

def puts_editor_usage(offset)
  cmd2 = "Usage : rake editor adventure=ADVENTURE_NAME [level=PUZZLE_NAME]"
  puts offset + cmd2
  ex = "Example : rake editor adventure=foobar level=level_1"
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

# -----------
# Cleanup

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

# ----------------
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

def debian_top_folder_name
  "boots-puzzle_#{BP_VERSION}_i386"
end

def debian_control_folder_name
  debian_top_folder_name + "/DEBIAN"
end
  
def debian_binaries_folder_name
  debian_top_folder_name + "/usr/games"
end

def debian_app_folder_name
  debian_top_folder_name + "/usr/share/boots-puzzle"
end

def debian_doc_folder_name
  debian_top_folder_name + "/usr/share/doc/boots-puzzle"
end


task :make_debfolder do
  puts "Generating deb folder..."
  FileUtils.rm_rf(debian_top_folder_name)
  FileUtils.mkdir_p(debian_top_folder_name)
  FileUtils.mkdir_p(debian_control_folder_name)
  FileUtils.mkdir_p(debian_binaries_folder_name,:mode => 0755)
  FileUtils.mkdir_p(debian_app_folder_name, :mode => 0755)
  FileUtils.mkdir_p(debian_doc_folder_name, :mode => 0755)
#  FileUtils.chown_R("root", "root", [debian_top_folder_name + "/usr"])
end

# Create a copyright file
def make_copyright
  from_template(debian_doc_folder_name + "/copyright", "templates/deb-pkg/copyright.erb")
end

def make_control_file
  from_template(debian_control_folder_name + "/control", "templates/deb-pkg/control.erb")
end

task :fill_debfolder => [:make_debfolder] do
  puts "Copying docs..."
  # Generate and copy the copyright file
  make_copyright
  # Generate and copy the control file
  make_control_file
  # Copy all source files
  puts "Copying source files..."
  FileUtils.cp_r("src/adventures", debian_app_folder_name)
  FileUtils.cp_r("src/plugins", debian_app_folder_name)
  FileUtils.cp_r("src/gui", debian_app_folder_name)
  FileUtils.cp("src/boots-puzzle.rb", debian_app_folder_name)
  FileUtils.cp("src/boots-puzzle-wrapper.rb", debian_app_folder_name)
  # Copy binairies
  FileUtils.cp("misc/boots-puzzle", debian_binaries_folder_name)
  # Change the mode of the binaries
  FileUtils.chmod(0755, debian_binaries_folder_name + "/boots-puzzle")
  # Copy and compress the change log file
  puts "Copying change logs..."
  FileUtils.cp("deb-pkg/changelog", debian_doc_folder_name)
  FileUtils.cp("deb-pkg/changelog", debian_doc_folder_name + "/changelog.Debian")
  puts "Compressing changelogs..."
  system("gzip -9 #{debian_doc_folder_name}/changelog")
  system("gzip -9 #{debian_doc_folder_name}/changelog.Debian")
end

task :deb => [:clean, :set_version, :test, :fill_debfolder] do
  system("dpkg -b #{debian_top_folder_name} boots-puzzle-#{BP_VERSION}-linux-2.6-intel.deb")
end

# TODO : Zip the change log file and move it

task :deblist  do
  $LOAD_PATH << "."
  # This will make what is needed in the script variable
  require 'boots-puzzle_list.rb'
  f = File.open(List, "w")
  f << Script
  f.close
end

desc "Create a debian package using epm"
task :deb_epm => [:clean, :set_version, :test, :deblist] do
  system("epm -f deb boots-puzzle")
end

# ----------------
# Apt repository

desc "Set up an apt-repository with the sources"
task :apt => [:deb] do
  FileUtils.rm_rf("apt")
  FileUtils.mkdir_p("apt/binary")
  FileUtils.mkdir_p("apt/sources")
  Dir["*.deb"].each do |file|
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

# -----------------
# Release

desc "Releases all artefacts for a new version"
task :release => [:doc, :apt, :package]

