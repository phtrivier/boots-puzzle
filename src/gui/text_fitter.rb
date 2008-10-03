# Boots Puzzle - text_fitter.rb
#
# A class to indicate whether text can fit in a zone
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

class TextFitter

  def initialize(font, max_width)
    @font = font
    @max_width = max_width
  end

  def fit?(text)
    # TODO : If using true type font, make
    # it nicer
#    @font.text_width(text) < @max_width
    @font.width * text.size < @max_width
  end

  def tokens_fit?(tokens)
    # TODO : OPTIMZE THIS
    # Use the size of a space
    #    space_size = window.font.text_width(" ")
    # Compute the size of each tokens, then
    # compare with the max size
    fit?(tokens.join(" "))
  end

end
