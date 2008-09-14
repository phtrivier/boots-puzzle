# Boots Puzzle - quote_test.rb
#
# Test for quotes
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

require 'quote'

class QuoteTest < BPTestCase

  def test_quote_works
    q = Quote.new({:author =>"me", :text => "blah blah"})
    assert_equal "me", q.author
    assert_equal "blah blah", q.text

    q = Quote.new(:text => "bip bip")
    assert_nil q.author
    assert_equal "bip bip", q.text

  end

  def test_quote_graciously_ignores_bad_quotes_definition
    q = Quote.new()
    assert_nil q.author
    assert_equal "", q.text

    q = Quote.new({ :author => "toto"})
    assert_equal "toto", q.author
    assert_equal "", q.text

    q = Quote.new({ :foo => "bar"})
    assert_nil q.author
    assert_equal "", q.text
  end

  def test_serialize_quote
    q = Quote.new(:text => "bip bip")

    e = <<HERE
 quote :text => "bip bip"
HERE

    assert_equal e, q.serialize(" ") + "\n"
  end

end
