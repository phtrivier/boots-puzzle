require 'player'

require 'test/unit'

class PlayerTest < Test::Unit::TestCase

  def setup
    @p = Player.new
  end

  def test_player_has_bare_feer_by_default
    assert_equal(BareFeet, @p.current_boots.class)
  end

  def test_player_has_no_boots_in_hand_by_default
    assert_nil(@p.boots_in_right_hand)
    assert_nil(@p.boots_in_left_hand)
    assert(@p.free_hand?)
  end

  def test_player_can_pick_boots
    b1 = Boots.new
    @p.pick!(b1)
    assert_equal(b1, @p.boots_in_right_hand)
    assert(@p.free_hand?)
    b2 = Boots.new
    @p.pick!(b2)
    assert_equal(b2, @p.boots_in_left_hand)
    assert(!@p.free_hand?)
    b3 = Boots.new
    begin
      @p.pick!(b3)
      assert(false, "Should not be possible to pick shoes with full hands")
    rescue RuntimeError => e
      assert_equal("No free hand to pick boots", e.message)
    end
  end

  def test_player_can_drop_boots
    b1 = Boots.new
    @p.pick!(b1)
    assert_equal(b1, @p.boots_in_right_hand)
    assert(@p.free_hand?)
    b2 = Boots.new
    @p.pick!(b2)
    assert_equal(b2, @p.boots_in_left_hand)
    assert(!@p.free_hand?)

    @p.drop!(:right)
    assert_nil(@p.boots_in_right_hand)
    b3 = Boots.new
    @p.pick!(b3)
    assert_equal(b3, @p.boots_in_right_hand)

    begin
      @p.drop!(:foo)
      assert(false, "Foo is not a valid side")
    rescue RuntimeError => e
      assert_equal("Wrong side to drop : foo", e.message)
    end
  end

  def test_player_can_put_boots_on_and_off
    # One pair of boots in hand
    b1 = Boots.new
    @p.pick!(b1)
    @p.put_on!(:right)
    assert_equal(b1, @p.current_boots)

    @p.put_off!
    assert_equal(BareFeet, @p.current_boots.class)
    assert_equal(b1, @p.boots_in_right_hand)

    # A second pair of boots in hand
    b2 = Boots.new
    @p.pick!(b2)
    @p.put_on!(:left)
    assert_equal(b2, @p.current_boots)

    @p.put_off!
    assert(@p.bare_feet?)
    assert_equal(b2, @p.boots_in_left_hand)

    # Now put on one of the pairs, and pick a
    # third one
    @p.put_on!(:right)
    b3 = Boots.new
    @p.pick!(b3)
    assert_equal(b1, @p.current_boots)
    assert_equal(b2, @p.boots_in_left_hand)
    assert_equal(b3, @p.boots_in_right_hand)
    # Put in on ; worn shoes goes in the free hand
    @p.put_on!(:right)
    assert_equal(b3, @p.current_boots)
    assert_equal(b2, @p.boots_in_left_hand)
    assert_equal(b1, @p.boots_in_right_hand)
    # Now put the current boots off : where does it go ?
    # By default, I exchange it with the right side
    @p.put_off!
    assert_equal(b1, @p.current_boots)
    assert_equal(b2, @p.boots_in_left_hand)
    assert_equal(b3, @p.boots_in_right_hand)
  end

end
