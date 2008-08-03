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

  LEFT_BUTTON = 1
  RIGHT_BUTTON = 3

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

        debug "Clicked on #{i}, #{j} ... original type was #{t}"

        if (b == LEFT_BUTTON)
          @new_type = @left_tool_type
        elsif (b == RIGHT_BUTTON)
          @new_type = @right_tool_type
        end
        debug "New type to be applied : #{@new_type}"
        @cells[i][j] = @new_type

        img.path = @new_type.new.src
        debug "New image path : #{img.path}"
        img.hide
        img.show

      end

    end
  end

  def index

    # FIXME : use unhardwired values
    @w = 10;
    @h = 7;

    @cells = []

    @new_type = Wall

    @left_tool_img =  nil
    @left_tool_type = nil
    @right_tool_img = nil
    @right_tool_type = nil

    show_editor
  end

  def cell_button(klass)

    stack :width => "50%" do
      image klass.new.src

      click do |b,l,t|

        debug "Value of b : #{b}"
        debug "Is it left ? #{b == LEFT_BUTTON}. Is it 1 ? #{b == 1}.}"
        debug "Is it right ? #{b == RIGHT_BUTTON}. Is it 3 ? #{b == 3}.}"

        if (b == LEFT_BUTTON)
          debug "left, new path : #{klass.new.src}"
          @left_tool_img.path = klass.new.src
          @left_tool_img.hide
          @left_tool_img.show
          @left_tool_type = klass
        elsif (b == RIGHT_BUTTON)
          debug "right, new path : #{klass.new.src}"
          @right_tool_img.path = klass.new.src
          @right_tool_img.hide
          @right_tool_img.show
          @right_tool_type = klass
        end

      end

    end

  end

  def show_editor
    flow do
      stack :width => '20%' do
        border black, :strokewidth => 1

        para "Available tools"

        stack do
          border black, :strokewidth => 1
          # TODO : Make this more generic by
          # Loading all the sub-classes of Cell
          # and cutting them in three (quite easy, actually !!)
          flow :margin_top => '5px', :margin_left => '5px' do
            cell_button(In)
            cell_button(Out)
          end

          flow :margin_top => '5px', :margin_left => '5px' do
            cell_button(Wall)
            cell_button(Walkable)
          end

        end

        para "Selected tools"
        stack do
          border black, :strokewidth => 1
          para "Left"
          @left_tool_type = Wall
          @left_tool_img = image @left_tool_type.new.src
          para "Right"
          @right_tool_type = Walkable
          @right_tool_img = image @right_tool_type.new.src
        end

      end

      stack :width => '60%' do
        border black, :strokewidth => 1

        (0..@h).each do |i|
          # debugs "adding a row ? "
          @cells[i] = []
          flow :margin => 5 do
            @w.times do |j|

              # debugs "adding a cell ?"

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
