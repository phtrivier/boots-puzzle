# Boots Puzzle - puzzle_quote_test.rb
#
# Tests for adding a quote to a puzzle
#
# Copyright (C) 2008 Pierre-Henri Trivier
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA

require 'bp_test_case'

class PuzzleQuoteTest < BPTestCase

  def test_define_quote_on_puzzle
    pu = Puzzle.empty(3,3)
    assert_nil pu.quote
    pu.add_quote({ :author => "Pierre Desproges", :text => "Vivons heureux..."})
    assert_equal("Pierre Desproges", pu.quote.author)
    assert_equal("Vivons heureux...", pu.quote.text)
  end

  class PuzzleWithQuote < Puzzle
    dim 3,1
    rows do
      row "I-O"
    end
    quote :author => "Pierre Desproges",
    :text => "Vivons heureux..."
  end

  def test_loads_puzzle_with_quote_definition
    pu = PuzzleWithQuote.new
    assert_equal "Pierre Desproges", pu.quote.author
    assert_equal "Vivons heureux...", pu.quote.text
  end

  def test_serializing_puzzle_with_quote
    pu = PuzzleWithQuote.new
    s = pu.serialize("PuzzleWithQuote")
    expected = <<HERE
class PuzzleWithQuote < Puzzle
 dim 3,1
 rows do
  row "I-O"
 end
 quote :author => "Pierre Desproges",
 :text => "Vivons heureux..."
end
HERE
    assert_equal expected, s
  end

  def test_serializing_puzzle_with_partial_quote
    pu = Puzzle.empty(2,1)
    pu.add_quote(:text => "Toto")
    s = pu.serialize("PuzzleWithQuote")
    expected = <<HERE
class PuzzleWithQuote < Puzzle
 dim 2,1
 rows do
  row "--"
 end
 quote :text => "Toto"
end
HERE
    assert_equal expected, s
  end


end
