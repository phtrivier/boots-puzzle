# Boots Puzzle - text_cutter_test.rb
#
# Test for the TextCutter class
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

require 'text_cutter'

class TextCutterTest < BPTestCase

  def test_keeps_text_that_fits_as_such
    text = "Hello world !"
    fitter = mock()
    fitter.expects(:fit?).with(text).returns(true)

    c = TextCutter.new(fitter)
    elements = c.cut_text(text)
    assert_equal [text], elements
  end

  def test_cuts_line_at_new_lines
    text = "Hello world !\nHow are you doing ?"

    assert_equal 2, text.split("\n").size

    f = mock()
    f.expects(:fit?).with("Hello world !").returns(true)
    f.expects(:fit?).with("How are you doing ?").returns(true)

    c = TextCutter.new(f)
    e = c.cut_text(text)
    assert_equal(["Hello world !", "How are you doing ?"], e)
  end

  def test_cuts_line_if_it_does_not_fit
    line = "Hello everyone ! I am happy !"
    f = mock()
    f.expects(:tokens_fit?).with(line.split(" ")).returns(false)
    f.expects(:tokens_fit?).with("Hello everyone ! I am happy".split(" ")).returns(false)
    f.expects(:tokens_fit?).with("Hello everyone ! I am".split(" ")).returns(false)
    f.expects(:tokens_fit?).with("Hello everyone ! I".split(" ")).returns(true)
    f.expects(:tokens_fit?).with("am happy !".split(" ")).returns(true)

    c = TextCutter.new(f)
    e = c.cut_line(line)
    assert_equal(["Hello everyone ! I", "am happy !"], e)
  end

  def test_recusively_cuts_line_if_it_does_not_fit
    line = "Hello everyone-from-everywhere ! I am so happy !"
    f = mock()
    f.expects(:tokens_fit?).with(line.split(" ")).returns(false)
    f.expects(:tokens_fit?).with("Hello everyone-from-everywhere ! I am so happy".split(" ")).returns(false)
    f.expects(:tokens_fit?).with("Hello everyone-from-everywhere ! I am so".split(" ")).returns(false)
    f.expects(:tokens_fit?).with("Hello everyone-from-everywhere ! I am".split(" ")).returns(false)
    f.expects(:tokens_fit?).with("Hello everyone-from-everywhere ! I".split(" ")).returns(false)
    f.expects(:tokens_fit?).with("Hello everyone-from-everywhere !".split(" ")).returns(true)
    f.expects(:tokens_fit?).with("I am so happy !".split(" ")).returns(false)
    f.expects(:tokens_fit?).with("I am so happy".split(" ")).returns(false)
    f.expects(:tokens_fit?).with("I am so".split(" ")).returns(true)
    f.expects(:tokens_fit?).with("happy !".split(" ")).returns(true)
    c = TextCutter.new(f)
    e = c.cut_line(line)
    assert_equal(["Hello everyone-from-everywhere !", "I am so", "happy !"], e)
  end

  def test_cuts_lines_then_line_recursively
    text = "Hi !\nHello everyone-from-everywhere ! I am so happy !"
    f = mock()
    f.expects(:fit?).with("Hi !").returns(true)
    f.expects(:fit?).with("Hello everyone-from-everywhere ! I am so happy !").returns(false)
    f.expects(:tokens_fit?).with("Hello everyone-from-everywhere ! I am so happy !".split(" ")).returns(false)
    f.expects(:tokens_fit?).with("Hello everyone-from-everywhere ! I am so happy".split(" ")).returns(false)
    f.expects(:tokens_fit?).with("Hello everyone-from-everywhere ! I am so".split(" ")).returns(false)
    f.expects(:tokens_fit?).with("Hello everyone-from-everywhere ! I am".split(" ")).returns(false)
    f.expects(:tokens_fit?).with("Hello everyone-from-everywhere ! I".split(" ")).returns(false)
    f.expects(:tokens_fit?).with("Hello everyone-from-everywhere !".split(" ")).returns(true)
    f.expects(:tokens_fit?).with("I am so happy !".split(" ")).returns(false)
    f.expects(:tokens_fit?).with("I am so happy".split(" ")).returns(false)
    f.expects(:tokens_fit?).with("I am so".split(" ")).returns(true)
    f.expects(:tokens_fit?).with("happy !".split(" ")).returns(true)
    c = TextCutter.new(f)
    e = c.cut_text(text)
    assert_equal(["Hi !", "Hello everyone-from-everywhere !", "I am so", "happy !"], e)
  end



end
