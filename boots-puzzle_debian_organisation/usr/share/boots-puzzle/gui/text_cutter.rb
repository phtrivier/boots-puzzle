# Boots Puzzle - text_cutter.rb
#
# A class to help cutting a text in pieces that fit on the screen
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

class TextCutter

  attr_reader :fitter

  def initialize(fitter)
    @fitter= fitter
  end

  # Separate a block of text into lines that should
  # fit in the width of a screen, as indicated by
  # fitter.fit? and fitter.tokens_fit?
  # Newlines should be respected.
  def cut_text(text)
    res = []
    text.split("\n").each do |line|
      if (@fitter.fit?(line))
        res << line
      else
        res = res + cut_line(line)
      end
    end
    res
  end

  # Separate a single line of text between one
  # or several lines that should fit in
  # the width (as provided bu fitter.tokens_fit?)
  def cut_line(line)
    cut_line_helper(line.split(" "))
  end

  # Rather intricated version
  # This can probably be optimised, improved,
  # or made more functionnal ...
  def cut_line_helper(tokens)
    if (tokens == [])
      return []
    end

    end_index = tokens.size - 1
    fitting = false

    while (not fitting and end_index > 0)
      if (@fitter.tokens_fit?(tokens[0..end_index]))
        fitting = true
      else
        end_index = end_index - 1
      end
    end

    first_line = tokens[0..end_index].join(" ")
    remaining = tokens[end_index+1..-1]

    res = [first_line] + cut_line_helper(remaining)

  end

end
