require 'plugin_test_case'

class EventsTest < PluginTestCase
  tested_plugin :events

  class SamplePuzzle < Puzzle
    dim 2,2
    rows do
      row "I-"
      row "-O"
    end

    named_cells do
      named_cell :foo , 0, 1
      named_cell :bar, 1, 0
    end
  end

  def test_once_for_all_on_one_cell
    pu = SamplePuzzle.new

    m = mock()

    pu.story_once_for_all [:foo, :bar] do |pu, called, count|
      m.called(pu, called, count)
    end
    # M should be called only once for each creation of the
    # puzzle, even when we moved several time on
    # the cell.
    m.expects(:called).with(pu, false, 0).times(1)

    pu.enters_player!
    pu.try_move!(:right)
    pu.try_move!(:left)
    pu.try_move!(:down)

  end

  def test_once_for_all_on_other_cell
    pu = SamplePuzzle.new

    m = mock()

    pu.story_once_for_all [:foo, :bar] do |pu, called, count|
      m.called(pu, called, count)
    end
    # M should be called only once for each creation of the
    # puzzle, even when we moved several time on
    # the cell.
    m.expects(:called).with(pu, false, 0).times(1)

    pu.enters_player!
    pu.try_move!(:down)
    pu.try_move!(:up)
    pu.try_move!(:right)

  end

  def test_works_with_nothing_in_block
    pu = SamplePuzzle.new
    m = mock()
    pu.story_once_for_all [:foo, :bar] do |pu|
      m.baz(pu)
    end
    m.expects(:baz).with(pu)
    pu.enters_player!
    pu.try_move!(:down)
  end


end
