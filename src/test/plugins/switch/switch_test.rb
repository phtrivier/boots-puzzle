require 'plugin_test_case'

class SwitchTest < PluginTestCase
  tested_plugin :switch

  class TestPuzzle < Puzzle
    dim 3,1
    rows do
      row "I%O"
    end
    named_cells do
      named_cell :sw,0,1
    end
  end

  def test_defining_event_on_a_cell
    c = SwitchCell.new
    pu = mock()
    m = mock()
    m.expects(:switched).with(:on, pu)
    m.expects(:switched).with(:off, pu)
    c.on do |pu|
      m.switched(:on, pu)
    end
    c.off do |pu|
      m.switched(:off, pu)
    end
    c.switch_on!(pu)
    c.switch_off!(pu)
  end

  def test_state_is_switched_on_contact
    c = SwitchCell.new
    pu = mock()
    m = mock()
    m.expects(:switched).with(:on, pu)
    m.expects(:switched).with(:off, pu)
    c.on do |pu|
      m.switched(:on, pu)
    end
    c.off do |pu|
      m.switched(:off, pu)
    end
    c.force_on!(true)
    assert c.on?
    c.static_contact!(pu,:top)
    assert c.off?
    c.static_contact!(pu, :top)
    assert c.on?
  end


  def test_you_can_define_events_on_a_switch_cell
    pu = TestPuzzle.new
    m = mock()
    # Define switch events on cell named "sw"
    pu.story_switch :sw do
      on do |pu|
        m.switched(:on)
      end
      off do |pu|
        m.switched(:off)
      end
    end
    # Check that the switch is off at startup (default)
    c = pu.cell_by_name(:sw)
    assert_equal SwitchCell, c.class
    assert c.off?
    assert !c.on?

    pu.enters_player!
    # Mock will check if the callbacks are called
    m.expects(:switched).with(:on)
    pu.try_move!(:right)
    # Player hasn't move
    assert_equal [0,0], pu.player.pos
    # State has changed
    assert c.on?
    assert !c.off?

    # Now toggle it another time
    m.expects(:switched).with(:off)
    pu.try_move!(:right)
    # Player hasn't move
    assert_equal [0,0], pu.player.pos
    # State is back to the original
    assert c.off?
    assert !c.on?
  end

  def test_you_can_declare_that_a_switch_cell_is_off_by_default
    pu = TestPuzzle.new
    c = pu.cell_by_name(:sw)
    pu.story_switch :sw , :start => :on do
      on do |pu|
      end
      off do |pu|
      end
    end
    assert c.on?
    assert !c.off?
  end

  def test_switch_icon_changes_depending_on_the_state
    c = SwitchCell.new
    pu = mock()
    assert c.off?
    assert_equal "switch/img/switch_off.png", c.src
    c.switch_on!(pu)
    assert_equal "switch/img/switch_on.png", c.src
  end

  def test_switches_can_be_forced_to_stay_in_a_state
    c = SwitchCell.new
    pu = mock()
    c.on do |pu|
      c.settle!
    end
    assert c.off?
    c.switch_on!(pu)
    assert c.on?
    c.switch_off!(pu)
    assert c.on?
    c.switch_on!(pu)
    assert c.on?
  end

end
