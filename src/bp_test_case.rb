require "test/unit"

class BPTestCase < Test::Unit::TestCase
  def bad(msg)
    assert false, msg
  end

  def test_fake
    # A TEST NEED TO BE DEFINED TO KEEP RAKE HAPPY
  end

end
