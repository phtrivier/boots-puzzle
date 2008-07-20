require 'player'

require 'test/unit'

class PlayerTest < Test::Unit::TestCase

  def test_player_has_bare_feer_by_default
    p = Player.new
    assert_equal(BareFeet, p.current_boots.class)
  end

end
