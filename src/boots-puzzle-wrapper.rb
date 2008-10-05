def from_env(long, short, default)
  res = default
  if (ENV[long])
    res = ENV[long]
  elsif (ENV[short])
    res = ENV[short]
  end
  res
end

def wrap_play(prefix)
  adventure_name = from_env("adventure", "a", "foobar")
  level_name = from_env("level", "l", nil)
  play_adventure(adventure_name, level_name, prefix)
end

def play_adventure(adventure_name, level_name, prefix)
  require 'gui'
  play(:adventure_name => adventure_name, :level_name => level_name, :prefix => prefix)
end

# TODO : Display help if required
