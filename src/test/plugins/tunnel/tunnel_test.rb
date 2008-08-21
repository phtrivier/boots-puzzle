require "bp_test_case"

# You can expect that the plugins will be loaded by rake, can't you ?

require 'src/plugins/core/plugins.rb'
Plugins.init("src/plugins")
Plugins.read_manifests
Plugins.need("tunnel")

class TunnelPluginTest < BPTestCase

  class PuzzleWithTunnel < Puzzle

    dim 5,1

    rows do
      row "I---O"
    end

    named_cells do
      named_cell :in, 0,1
      named_cell :out, 0,3
    end

  end

  def test_puzzle_with_tunnel_inside

    pu = PuzzleWithTunnel.new
    pu.tunnel :in, :out

    pu.enters_player!
    pu.try_move!(:right)

    assert_equal [0,3], pu.player.pos

  end


end
