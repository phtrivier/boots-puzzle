require 'src/editor/tools'

class ToolsTest < BPTestCase

  def test_stack_can_act_and_undo_a_command

    s = ToolStack.new
    editor = mock("editor")
    state = mock("state")

    assert(s.empty?)
    s.undo!
    assert(s.empty?)

    tool = mock("tool")
    tool.expects(:record_state).with(editor, 1,2).returns(state)
    tool.expects(:act).with(editor, 1,2)
    s.command!(tool, editor, 1, 2)
    assert(!s.empty?)
    tool.expects(:undo!).with(state, editor)
    s.undo!
    assert(s.empty?)

  end

end


