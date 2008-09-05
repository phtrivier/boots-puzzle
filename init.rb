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

ARGV.each do |arg|
  [Regexp.new("--(.*)=(.*)"), Regexp.new("-(.*)=(.*)")].each do |r|
    m = arg.match(r)
    if (m!=nil)
      puts "#{m[1]}, #{m[2]}"
      ENV[m[1]] = m[2]
    end
  end
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

def oldlocation(str)
  return "./#{str}"
end

$LOAD_PATH << oldlocation("./src")
$LOAD_PATH << oldlocation("./src/gui")
$LOAD_PATH << oldlocation("./src/plugins/core")

FileUtils.mkdir_p("logs")
log_config("dev")

adventure_name = from_env("adventure", "a", "foobar")
level_name = from_env("level", "l", nil)

require oldlocation("src/gui/gui")
play(:adventure_name => adventure_name, :level_name => level_name, :prefix => oldlocation("."))
