require "test/unit"

class PluginTest < Test::Unit::TestCase
  def test_is_unmanifested_by_default
    pu = Plugin.new("toto", [])
    assert_equal :unmanifested, pu.status
  end
end
