require 'bp_test_case'

class FakeBoots < BareFeet
end

class BootsRegistryTest < BPTestCase

  def test_boots_can_be_created_and_registered_quickly
    Boots.for("foo", "FooBoots") do
    end
    assert_not_nil FooBoots
    f = FooBoots.new
    assert f.is_a?(Boots)
  end

  def test_methods_can_be_defined
    m = mock()

    Boots.for("bar", "BarBoots") do
      img "bar.png"
      reachable do |puzzle, i, j|
        m.reachable(puzzle, i, j)
      end
      next_position do |puzzle, dir|
        m.next_position(puzzle, dir)
      end
    end

    pu = Puzzle.empty(10,10)
    m.expects(:reachable).with(pu, 0, 1)
    m.expects(:next_position).with(pu, :up)

    b = BarBoots.new
    assert_equal "bar/img/bar.png", b.src
    b.reachable?(pu, 0, 1)
    b.next_position(pu, :up)
  end

  def test_some_methods_can_be_left_undefined
    Boots.for("baz", "BazBoots") do
      img "baz.png"
    end

    b = BazBoots.new
    pu = mock()
    pu.expects(:walkable?).with(0,1)
    b.reachable?(pu,0,1)
  end

  def test_boots_tools_can_be_defined_quickly
    BootsTool.for(FakeBoots)
    assert_not_nil FakeBootsTool
    assert ToolsRegistry.registered_boots_tools.member?(FakeBootsTool)
    editor = mock()
    puz = mock()
    editor.expects(:puzzle).returns(puz)
    puz.expects(:boot).with(0,1,FakeBoots)
    editor.expects(:update_editor_cell).with(0,1)

    tool = FakeBootsTool.new
    tool.act(editor, 0,1)

  end

end
