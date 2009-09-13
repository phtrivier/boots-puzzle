require 'plugin_test_case'

class EventsTest < PluginTestCase
  tested_plugin :chat

  def test_declaring_npc

    Chat.clear_chatters
    
    assert_nil Chat.find_chatter :bob

    Chat.chatter :bob, :name => "Bob", :sprite => "toto.gif"

    c = Chat.find_chatter :bob
    assert_not_nil c
    assert_equal "Bob" , c[:name]
    assert_equal "toto.gif" , c[:sprite]

  end

  class MockMessageListener
    attr_reader :message_read
    def handle_message(options)
      @message_read = options[:msg]
    end
  end


  def test_chat_message_are_prefixed_with_the_name_of_current_chatter
    pu = Puzzle.empty(10,10)

    m = MockMessageListener.new
    pu.add_listener(m)

    pu.current_chatter = {:name => "Bob"}
    pu.chat "Hello !"

    assert_equal "Bob says : 'Hello !'", m.message_read

  end

  def test_adding_a_chat_cell

    pu = Puzzle.empty(10,10)
    pu.named_cell :cell1, 0, 0

    m = MockMessageListener.new
    pu.add_listener(m)

    Chat.chatter :bob, :name => "Bob", :sprite => "toto.gif"

    @read_count = 0

    pu.chatter :cell1, :bob do |puzzle, count|
      @read_count = count
      pu.chat @read_count
    end

    chat_cell = pu.cell_by_name(:cell1)

    assert_equal ChatCell, chat_cell.class
    assert_equal "Bob", chat_cell.chatter[:name]
    assert_equal 0, chat_cell.chat_count

    chat_cell.static_contact!(pu, :up)
    assert_equal 1, @read_count
    assert_equal "Bob says : '1'", m.message_read

    chat_cell.static_contact!(pu, :up)
    assert_equal 2, @read_count
    assert_equal "Bob says : '2'", m.message_read

    # Several images have to be drawn so that the chatter appears
    # correcly
    assert_equal ["core/img/walkable.png", "toto.gif"], chat_cell.src

  end


end
