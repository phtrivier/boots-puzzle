require "test/unit"
require "rubygems"
require 'mocha'

class BPTestCase < Test::Unit::TestCase
  def bad(msg)
    assert false, msg
  end

  def test_fake
    # A TEST NEED TO BE DEFINED TO KEEP RAKE HAPPY
  end

  def assert_point_equal(i,j,k,l)
    assert_equal(i,k, "Line index should be equals")
    assert_equal(j,l, "Column index should be equals")
  end

end
