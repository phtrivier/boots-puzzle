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
require 'tools'

class EditorCell < Struct.new(:type, :img, :boot_img, :name_img)
end

# A location for a selected tool
class ToolSlot
  attr_reader :img
  attr_reader :tool

  def initialize(tool, img)
    @tool = tool
    @img = img
  end

  def set_tool(tool)
    @tool = tool
    @img.path = tool.src
    @img.hide
    @img.show
  end
end

class Editor < Shoes
  url '/', :index

  LEFT_BUTTON = 1
  RIGHT_BUTTON = 3
  Transparent = "img/transparent.png"

  attr_reader :puzzle

  # ----------------------------------------

  # Main page
  def index
    @cells = []

    @new_type = Wall

    @tool_slots = { }

    @named_cell_icons = NameCellTool::Icons
    @named_cell_icon_index = 0

    load_or_init_puzzle
    show_editor
  end

  def load_or_init_puzzle
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
  end

  def init_new_puzzle
    # TODO : Create a dialog to ask ...
    @puzzle_class = "FooPuzzle"
    @file_name = "foo_puzzle.rb"
    @puzzle = Puzzle.empty(10, 10)
  end

  # Main page
  def show_editor
    flow do
      stack :width => '20%' do
        build_palette_panel
      end

      stack :width => '60%' do
        build_puzzle_grid_panel
      end

      stack :width => '20%' do
        build_named_cells_panel
      end
    end

    flow do
      build_controls_panel
    end

    keypress do |k|
      if (k==:control_s)
        save_puzzle
      elsif (k==:control_q)
        if (@dirty_state != "" and confirm("Save before quitting ?"))
          save_puzzle
        end
        exit
      end
    end

  end


  # Builds a palette of available tools
  def build_palette_panel
    border black, :strokewidth => 1

    para "Available tools"

    stack :width => "90%" do
      border black, :strokewidth => 1
      # TODO : Make this more generic by
      # Loading all the sub-classes of Cell
      # and cutting them in three (quite easy, actually !!)
      flow :margin_top => '5px', :margin_left => '5px' do
        cell_tool_button(InTool.new())
        cell_tool_button(OutTool.new())
      end

      flow :margin_top => '5px', :margin_left => '5px' do
        cell_tool_button(CellTool.new(Wall))
        cell_tool_button(CellTool.new(Walkable))
      end

      flow :margin_top => '5px', :margin_left => '5px' do
        cell_tool_button(NameCellTool.new)
      end


    end

    para "Available boots"
    stack :width => "90%" do
      border black, :strokewidth => 1
      flow :margin_top => '5px', :margin_left => '5px' do
        cell_tool_button(BootsTool.new(DoubleBoots))
        cell_tool_button(ResetBootsTool.new())
      end
    end

    para "Selected tools"
    flow :width => "90%" do
      border black, :strokewidth => 1
      stack :width => '50%' do
        para "Left"
        @tool_slots[:left] = init_tool_slot(Wall)
      end

      stack :width => '50%' do
        para "Right"
        @tool_slots[:right] = init_tool_slot(Walkable)
      end

    end

  end

  def init_tool_slot(type)
    # This works because I am creating CellTool ...
    tool = CellTool.new(type)
    img = image tool.src
    tool_slot = ToolSlot.new(tool, img)
    tool_slot
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
          update_editor_cell(i,j)
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
    @dirty_state = para ""
  end

  # ----------------------------------------------------
  # Callbacks

  # Save the puzzle
  def save_puzzle
    res = @puzzle.serialize(@puzzle_class)
    debug res
    File.open(@file_name, "w+") do |f|
      f << res
    end
    @dirty_state.text = ""
  end

  def create_named_cells_list
    @named_cells_list = stack do
    end
    update_named_cells_list
  end

  # Update the list of named cells
  def update_named_cells_list
    @named_cells_list.clear

    @cells.each do |line|
      line.each do |c|
        c.name_img.path = Transparent
      end
    end

    @named_cell_icon_index = 0

    @puzzle.named_cells.each do |name, pos|

      icon = next_named_cell_icon

      @named_cells_list.append do
        flow do
          flow :width => "40%" do
             image icon
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
        i,j = pos
        @cells[i][j].name_img.path = icon
      end
    end
  end

  def next_named_cell_icon
    res = @named_cell_icons[@named_cell_icon_index]
    @named_cell_icon_index = (@named_cell_icon_index + 1) % @named_cell_icons.size
    res
  end

  # Create an image for a cell, on which one can click to change its type
  # i,j : position of the cell
  # t : type of cell at time of creation
  def create_cell_image(i, j, t)
    flow :width => '40px' do
      b = border black, :strokewidth => 1

      img = image t.new.src

      name_img = image Transparent
      name_img.move(0,0)

      boot_img = image Transparent
      boot_img.move(0,0)

      @cells[i][j] = EditorCell.new(t, img, boot_img, name_img)

      click do |b, l, t|

        debug "Clicked on #{i}, #{j} ... original type was #{t}"

        if (b == LEFT_BUTTON)
          @tool_slots[:left].tool.act(self, i,j)
          dirty(true)
        elsif (b == RIGHT_BUTTON)
          @tool_slots[:right].tool.act(self, i,j)
          dirty(true)
        end

      end

    end
  end

  def dirty(state)
    if (state)
      @dirty_state.text = "(modified)"
    else
      @dirty_state.text = ""
    end
    @dirty_state.hide
    @dirty_state.show
  end

  # Update a cell in the grid
  def change_editor_cell(i,j,t)
    debug "Updating cell at #{i},#{j} - type to be applied : #{t}"
    @puzzle.set_cell(i,j, t.new)
    # TODO : CLEAN THE STRUCT, THERE SHOULD BE ONLY IMAGE ?
    img = @cells[i][j].img # Replace if with a list of images ...
    img.path = t.new.src
    update_editor_cell(i,j)
  end

  def update_editor_cell(i,j)
    # Update main part of the cell
    img = @cells[i][j].img
    img.hide
    img.show
    # Update extra part of the cell (boots?)
    b = @puzzle.boot_at(i,j)
    img = @cells[i][j].boot_img
    if ( b != nil)
      img.path = b.src
    else
      img.path = Transparent
    end
    img.hide
    img.show
  end

  # A button to toggle the current tool
  def cell_tool_button(tool)
    stack :width => "50%" do
      image tool.src

      click do |b,l,t|
        if (b == LEFT_BUTTON)
          @tool_slots[:left].set_tool(tool)
        elsif (b == RIGHT_BUTTON)
          @tool_slots[:right].set_tool(tool)
        end
      end
    end
  end


end

Editor.app :title => "Puzzle editor", :width => 1000