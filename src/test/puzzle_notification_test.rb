require 'bp_test_case'

class PuzzleNotificationTest < BPTestCase

  def test_listeners_are_notified_when_an_event_is_fired
    pu = Puzzle.empty(2,2)
    listener1 = mock()
    listener2 = mock()

    listener1.expects(:respond_to?).with(:handle_foo).returns(true)
    listener1.expects(:send).with(:handle_foo, {:msg => "Foo"})
    listener2.expects(:respond_to?).with(:handle_foo).returns(false)

    pu.add_listener(listener1)
    pu.add_listener(listener2)

    assert_equal [listener1, listener2], pu.listeners

    pu.fire!(:foo, { :msg => "Foo"})
  end

  def test_short_hand_for_messages_info_and_error
    pu = Puzzle.empty(1,1)
    l1 = mock()
    l1.expects(:respond_to?).with(:handle_message).returns(true)
    l1.expects(:send).with(:handle_message, { :msg => "Foo"})
    l1.expects(:respond_to?).with(:handle_info).returns(true)
    l1.expects(:send).with(:handle_info, { :msg => "Bar"})
    l1.expects(:respond_to?).with(:handle_error).returns(true)
    l1.expects(:send).with(:handle_error, { :msg => "Baz"})

    pu.add_listener l1

    pu.message("Foo")
    pu.info("Bar")
    pu.error("Baz")

  end

end
