# Boots Puzzle - quote.rb
#
# A quote (to be displayed before a puzzle)
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

class Quote < Struct.new(:author, :text)
  def initialize(ops = {})
    super(ops[:author], ops[:text] || "")
  end

  def serialize(prefix)
    res = ""
    if (!blank?)
      if (author == nil || author == "")
        if (text != nil)
          res = "#{prefix}quote :text => #{text.inspect}"
        end
      else
        res = "#{prefix}quote :author => #{author.inspect},\n"
        res = res + "#{prefix}:text => #{text.inspect}"
      end
    end
    res
  end

  def blank?
    (author == nil || author == "") and (text == nil || text == "")
  end

end
