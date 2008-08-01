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

require 'puzzle'


class Editor < Shoes
  url '/', :index

  def cell(i, j, t)
    stack :width => '40px' do
      b = border black, :strokewidth => 1

      @cells[i][j] = t
      img = image Walkable.new.src

      click do |b, l, t|

        # TODO : Check if it is the starting of a zone or the end of a zone ...
        # Store the dimensions somewhere ...
        # Then change all the zones as required !!
        # TODO : ADD THE HOVER TO CHANGE THE BACKGROUND COLOR IF REQUIRED

        puts "Clicked on #{i}, #{j} ... original type was #{t}"

        @cells[i][j] = @new_type
        puts img.path
        img.remove
        img = image @new_type.new.src

        puts img.path

      end

    end
  end

  def index

     # FIXME : use unhardwired values
    @w = 10;
    @h = 7;

    @cells = []

    @new_type = Wall

    show_editor
  end

  def show_editor
    flow do
      stack :width => '20%' do
        border black, :strokewidth => 1
        para "list of available tools"
        para "list of selected tools"
      end

      stack :width => '60%' do
        border black, :strokewidth => 1

        (0..@h).each do |i|
          # puts "adding a row ? "
          @cells[i] = []
          flow :margin => 5 do
            @w.times do |j|

              # puts "adding a cell ?"

              cell(i, j , Walkable)

            end

          end

        end

      end

      stack :width => '20%' do
        border black, :strokewidth => 1

        para "list of special cells (with positions)"

      end
    end
  end

end

Editor.app :title => "Puzzle editor", :width => 800
