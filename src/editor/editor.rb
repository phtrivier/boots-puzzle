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

$LOAD_PATH << "../plugins/core"
$LOAD_PATH << "../adventures"
$LOAD_PATH << "."

require 'adventure'
require 'puzzle'
require 'tools'
require 'fileutils'
require 'adventure_loader'


# ----------------------
# Init the plugins > This will be done in the adventure aftewards ?
require 'plugins'

# ----------------------

module ImagePath
  def to_image_path(src)
    "../plugins/#{src}"
  end
end

class EditorCell < Struct.new(:type, :img, :boot_img, :name_img)
end

# A location for a selected tool
class ToolSlot
  include ImagePath

  attr_reader :img
  attr_reader :tool

  def initialize(tool, img)
    @tool = tool
    @img = img
  end

  def set_tool(tool)
    @tool = tool
    @img.path = to_image_path(tool.src)
    @img.hide
    @img.show
  end
end

class LevelEditor < Shoes

  include ImagePath

 url '/', :index

  LEFT_BUTTON = 1
  RIGHT_BUTTON = 3
  Transparent = "./img/transparent.png"

  attr_accessor :puzzle

  #----------------------------------------

  # Main page
  def index
     @cells = []

     @new_type = Wall

     @tool_slots = { }

     @named_cell_icons = NameCellTool::Icons
     @named_cell_icon_index = 0

     load_adventure
     # load_or_init_puzzle

     @command_stack = ToolStack.new

     show_editor
  end

  def load_adventure

    if (ARGV[1] == nil)
      alert("You need to give the name of an adventure.")
      close
      exit
    else
      @adventure_name = ARGV[1]
      @prefix = ".."

      @adventure_loader = AdventureLoader.new(@prefix, ["../adventures"])

      @adventure = @adventure_loader.load!(@adventure_name)
      if (@adventure == nil) 
        alert("The adventure could not be loaded")
        exit
      end

      if (ARGV[2] == nil)
        alert("No puzzle name given ... We'll create a new one ")
        create_new_puzzle
        exit
      else
        puzzle_name = ARGV[2]

        if (@adventure_loader.adventure.has_level_named?(puzzle_name))
          @adventure_loader.load_level(puzzle_name)
        else
          if (!confirm("There is no puzzle with the name #{puzzle_name} in adventure #{@adventure_name}" +
                       ". Do you want to create one ?"))
            close
          else
            create_new_puzzle(puzzle_name)
          end
        end
      end

      @puzzle = @adventure_loader.puzzle

    end

  end

  # There should be no spaces ...
  def valid_puzzle_name?(str)
    !str.include?(" ")
  end

  def create_new_puzzle(puzzle_name=nil)
    # TODO : Make this method shorter ?
    h = Puzzle::MAX_H
    w = Puzzle::MAX_W
    all_good = true

    puzzle_name = ask "What is the name of the puzzle ?" unless puzzle_name
    puzzle_name = puzzle_name.strip

    if (puzzle_name == nil)
      all_good = false
    else
      if (!valid_puzzle_name?(puzzle_name))
        alert("Invalid puzzle name, sorry...")
        all_good = false
      else
        if (!confirm "Do you want standard size (#{h} lines, #{w} columns ?)")
          all_good = false
          h_dialog = ask "How many lines ?"
          if (h_dialog.to_i <= 0)
            alert("Bad dimension")
            close
            exit
          else
            w_dialog = ask "How many columns ?"
            if (w_dialog.to_i <= 0)
              alert("Bad dimension")
              close
              exit
            else
              all_good = true
              h = h_dialog.to_i
              w = w_dialog.to_i
            end
          end
        end
      end
    end

    if (!all_good)
      alert("Some entry sucked, sorry...")
      close
      exit
    else
      @adventure_loader.add_level(puzzle_name, w, h)
    end

  end

  # Main page
  def show_editor

    flow do
      flow :width => "60%" do
        build_names_panel
      end
      flow :width => "40%" do
        build_controls_panel
      end
    end

    flow do
      stack :width => '10%' do
        build_palette_panel
      end

      stack :width => '70%' do
        build_puzzle_grid_panel
      end

      stack :width => '20%' do
        build_named_cells_panel
      end
    end

    flow do
      build_quote_panel
    end

    keypress do |k|
      if (k==:control_s)
        save_and_undirty
      elsif (k==:control_z)
        @command_stack.undo!
      elsif (k==:control_q)
        if (@dirty_state != "" and confirm("Save before quitting ?"))
          save_puzzle
        end
        exit
      end

      debug "Keypress handler for second stuff, key was #{k}"
      if (k==:control_w)
        @left_locked = !@left_locked
      elsif (k==:control_x)
        @right_locked = !@right_locked
      end
      update_lock_state

    end

  end

  def update_lock_state
    msg = ""
    if (@left_locked)
      msg = msg + "L"
    end
    if (@right_locked)
      msg = msg + "R"
    end
    @locked_state.text = msg
  end

  def build_names_panel
    para "Adventure name : "
    para @adventure.name
    para "--"
    para "Puzzle name : "
    para @adventure_loader.level.puzzle_name
  end

  def make_cell_tools_line(tools, length)
    buffer = []
    tools.each do |tool|
      if (buffer.size < length)
        buffer << tool
      else
        build_available_tool_line(buffer)
        buffer = [tool]
      end
    end
    if (!buffer.empty?)
      build_available_tool_line(buffer)
    end
  end

  def build_available_tool_line(tools)
    flow :margin_top => 5, :margin_left => 5 do
      tools.each do |tool|
        cell_tool_button(tool)
      end
    end
  end

  # Builds a palette of available tools
  def build_palette_panel
    border black, :strokewidth => 1

    para "Available tools"

    stack :width => "90%" do
      border black, :strokewidth => 1

      tools = [InTool.new, OutTool.new,
               CellTool.new(Wall), CellTool.new(Walkable),
               NameCellTool.new]

      ToolsRegistry.registered_cell_tools.each do |k|
        tools << k.new
      end

      make_cell_tools_line(tools, 3)

    end

    debug ToolsRegistry.registered_cell_tools

    para "Available boots"
    stack :width => "90%" do
      border black, :strokewidth => 1

      tools = [BootsTool.new(DoubleBoots),
               ResetBootsTool.new]

      ToolsRegistry.registered_boots_tools.each do |k|
        tools << k.new
      end

      make_cell_tools_line(tools, 3)

    end

    debug ToolsRegistry.registered_boots_tools

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
    img = image to_image_path(tool.src)
    tool_slot = ToolSlot.new(tool, img)
    tool_slot
  end

  def build_puzzle_grid_panel
    border black, :strokewidth => 1
    debug("Puzzle before grid_panel : #{@puzzle}")
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
      flow :width => "30%" do
        para "Position"
      end
      flow :width => "30%" do
        para "Name"
      end
      flow :width => "20%" do
        para ""
      end
    end

    create_named_cells_list
  end

  def save_and_undirty
    save_quote
    save_puzzle
    dirty(false)
  end

  def save_quote
    a = @quote_author.text
    t = @quote_text.text
    ops = { }
    if (a != nil)
      ops[:author] = a
    end
    if (t != nil)
      ops[:text] = t
    end
    @puzzle.add_quote(ops)
  end

  def build_quote_panel

    t = if @puzzle.quote != nil then @puzzle.quote.text end
    a = if @puzzle.quote != nil then @puzzle.quote.author || "" end
    para "Quote :"
    @quote_text = edit_box t , :width => 300, :height => 100

    @quote_text.change do
        dirty(true)
    end
    para "Author (optionnal) :"
    @quote_author = edit_line a, :heigth => 100

    @quote_author.change do
      dirty(true)
    end
  end

  def build_controls_panel
    button "save" do
      begin
        save_and_undirty
      rescue RuntimeError => e
        alert "Error while saving : #{e}"
      end
    end
    @dirty_state = para ""
    @locked_state = para ""
  end

  # ----------------------------------------------------
  # Callbacks

  # Save the puzzle
  def save_puzzle
    @adventure_loader.save_puzzle
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
          flow :width => "30%" do
             image to_image_path(icon)
            para "[#{pos[0]},#{pos[1]}]"
          end
          flow :width => "30%" do
            para name
          end
          flow :width => "20%" do
            button "X" do
              @puzzle.unname_cell(name)
              dirty(true)
              update_named_cells_list
            end
          end
        end
        i,j = pos
        @cells[i][j].name_img.path = to_image_path(icon)
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

      img = image to_image_path(t.new.src)

      name_img = image Transparent
      name_img.move(0,0)

      boot_img = image Transparent
      boot_img.move(0,0)

      @cells[i][j] = EditorCell.new(t, img, boot_img, name_img)

    
      click do |b, l, t|
        debug "Clicked on #{i}, #{j} ... original type was #{t}"

        # TODO : Actually, make a command with the tools, execute
        # the command, and put the command on top of the stack.
        # Then Implement undo! for each tools that I can use, and be done
        # with it !!

        tool = nil
        if (b == LEFT_BUTTON)
          tool = @tool_slots[:left].tool
        elsif (b == RIGHT_BUTTON)
          tool = @tool_slots[:right].tool
        end

        if (tool != nil)
          dirty(true)
          @command_stack.command!(tool, self, i,j)
        end
      end


      hover do |me|
        debug "Hovering on #{me} ; control or shift pressed : #{@left_locked}, #{@right_locked}"
        tool = nil
        if (@right_locked)
          tool = @tool_slots[:right].tool
        elsif (@right_locked)
          tool = @tool_slots[:locked].tool
        end
        if (tool != nil)
          dirty(true)
          @command_stack.command!(tool, self, i,j)
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
    img.path = to_image_path(t.new.src)
    update_editor_cell(i,j)
  end

  def editor_cell_type(i,j)
    @puzzle.cell(i,j).class
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
      img.path = to_image_path(b.src)
    else
      img.path = Transparent
    end
    img.hide
    img.show
  end

  # A button to toggle the current tool
  def cell_tool_button(tool)
    stack :width => "30%" do
      debug "Source : #{tool.src}"
      debug "Image path : #{to_image_path(tool.src)}"
      image to_image_path(tool.src)

      click do |b,l,t|
        if (b == LEFT_BUTTON)
          @tool_slots[:left].set_tool(tool)
        elsif (b == RIGHT_BUTTON)
          @tool_slots[:right].set_tool(tool)
        end
      end
    end
  end

  def add_named_cell(i,j, msg = "Name of the cell ?")
    name = ask msg
    begin
      @puzzle.named_cell(name.to_sym, i,j)
      update_named_cells_list
    rescue CellError => e
      alert(e.message)
    end
  end

  # TODO : Implement 'undoing' : each action should correspond to a
  # Command object, that goes into a stack ; 
  # each command is able to undo itself
  # TODO : Add a undo action on Ctrl-Z

end

LevelEditor.app :title => "Puzzle editor", :width => 380, :height => 480

