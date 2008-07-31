# Boots Puzzle - editor.rb
#
# Puzzle editor (shoes application)
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


class EditorCell
  attribute_accessor :type
  attribute_accessor :image
end

Shoes.app :title => "Puzzle editor" do

#   @w = ask "Puzzle\'s Width ?"

#   @w = @w.to_i

#   if (@w <= 0)
#     alert "Bad width !"
#     Kernel.exit(-1)
#     exit
#   end

#   @h = ask "Puzzle\'s Height ?"

#   @h = @h.to_i
#   if (@h <= 0)
#     alert "Bad Height !"
#     Kernel.exit(-1)
#     exit
#   end

  # FIXME : use unhardwired values
  @w = 10;
  @h = 7;

  @cells = []
  @h.times do
    @cells << []
  end

  flow do
    stack :width => '20%' do
      border black, :strokewidth => 1
      para "list of available tools"
      para "list of selected tools"
    end

    stack :width => '60%' do
      border black, :strokewidth => 1
      para "grid of selectable cells"
    end

    stack :width => '20%' do
      border black, :strokewidth => 1
      para "list of special cells (with positions)"
    end
  end
end
