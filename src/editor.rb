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

class EditorCell < Struct.new(:type, :img)
end

class Editor < Shoes
  url '/', :index

  LEFT_BUTTON = 1
  RIGHT_BUTTON = 3

    # Load the page

  # Main page
  def index
    @cells = []

    @new_type = Wall

    # TODO : move both in a proper structure (a nice array ;) )
    @left_tool_img =  nil
    @left_tool_type = nil
    @right_tool_img = nil
    @right_tool_type = nil

    if (ARGV[1] != nil and ARGV[2] != nil)
      @file_name = ARGV[1]
      @puzzle_class = ARGV[2]
      @puzzle = Puzzle.load(@file_name, @puzzle_class) do |f, k, e|
        alert("Unable to load puzzle #{k} from file #{f} ; #{e} " +
              "\n A new one will be created.")
        init_new_puzzle
      end
    else
      init_new_puzzle
    end

    puts @puzzle.w
    puts @puzzle.h
    puts @puzzle.cell(2,3).class

    show_editor
  end

  def init_new_puzzle
    # TODO : Create a dialog to ask ...
    @puzzle_class = "FooPuzzle"
    @file_name = "foo_puzzle.rb"
    @puzzle = Puzzle.empty(10, 10)
  end

  # i,j : position of the cell
  # t : type of cell at time of creation
  def create_cell_image(i, j, t)
    stack :width => '40px' do
      b = border black, :strokewidth => 1

      img = image t.new.src

      @cells[i][j] = EditorCell.new(t, img)

      click do |b, l, t|

        if (@named_cells_on)

          name = ask("Name of the cell ?")
          @puzzle.named_cell(name.to_sym, i,j)
          toggle_named_cells
          update_named_cells_list

        else

          debug "Clicked on #{i}, #{j} ... original type was #{t}"
          if (b == LEFT_BUTTON)
            @new_type = @left_tool_type
          elsif (b == RIGHT_BUTTON)
            @new_type = @right_tool_type
          end
          update_editor_cell(i,j,@new_type)

        end

      end

    end
  end

  def update_editor_cell(i,j,t)
    debug "Updating cell at #{i},#{j} - type to be applied : #{t}"
    @puzzle.set_cell(i,j, t.new)
    # TODO : CLEAN THE STRUCT, THERE SHOULD BE ONLY IMAGE ?
    img = @cells[i][j].img # Replace if with a list of images ...
    img.path = t.new.src
    debug "New image path : #{img.path}"
    img.hide
    img.show
  end

  # Save the puzzle (rudimentory, for the moment ...)
  def save_puzzle
    res = @puzzle.serialize(@puzzle_class)
    debug res
    File.open(@file_name, "w+") do |f|
      f << res
    end
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

    # Main page
  def show_editor
    flow do
      stack :width => '20%' do
        build_palette_panel
      end

      stack :width => '50%' do
        build_puzzle_grid_panel
      end

      stack :width => '30%' do
        build_named_cells_panel
      end
    end

    flow do
      build_controls_panel
    end
  end


  # Builds a palette of available tools
  def build_palette_panel
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

  def build_puzzle_grid_panel
    border black, :strokewidth => 1

    @puzzle.h.times do |i|
      # debugs "adding a row ? "
      # This is only the images ...
      @cells[i] = []
      flow :margin => 5 do
        @puzzle.w.times do |j|

          # debugs "adding a cell ?"
          create_cell_image(i,j, @puzzle.cell(i,j).class)
        end
      end
    end
  end

  def build_named_cells_panel
    border black, :strokewidth => 1

    para "Named cells"

    flow do
      flow :width => "40%" do
        para "Position"
      end
      flow :width => "40%" do
        para "Name"
      end

    end

    create_named_cells_list
  end

  def build_controls_panel
    button "save" do
      begin
        save_puzzle
      rescue RuntimeError => e
        alert "Error while saving : #{e}"
      end
    end

    button "name cell" do
      toggle_named_cells
    end

    @named_cell_status = para ""
    @named_cells_on = false
  end

  # Utilities
  def toggle_named_cells
    if (@named_cells_on)
      @named_cells_on = false
      @named_cell_status.hide
    else
      @named_cells_on = true
      @named_cell_status.text = "Click a cell to name it"
      @named_cell_status.hide
      @named_cell_status.show
    end
  end

  def create_named_cells_list
    @named_cells_list = stack do
    end
    update_named_cells_list
  end

  def update_named_cells_list
    @named_cells_list.clear
    @puzzle.named_cells.each do |name, pos|
      @named_cells_list.append do
        flow do
          flow :width => "40%" do
            para "[#{pos[0]},#{pos[1]}]"
          end
          flow :width => "40%" do
            para name
          end
          flow :width => "10%" do
            button "X" do
              @puzzle.unname_cell(name)
              update_named_cells_list
            end
          end
        end
      end
    end
  end

end

Editor.app :title => "Puzzle editor", :width => 1000
