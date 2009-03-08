# Boots Puzzle - tools.rb
#
# Tools for the editor
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

# A tool that act on a cell by changing its type
# by contract, Tools should provide :
#  src : a method to get the path to an image for the tool
#  act : the method to call when the tool is applied to the editor
require 'tools_registry'


# TODO : MAKE A TOOL ONLY FOR IN AND OUT
class GateTool < CellTool

  def act(editor, i, j)
    begin
      editor.change_editor_cell(i,j,@type)
    rescue ExitError => e
      alert("This puzzle already has #{@name}.Remove it first.")
    end
  end

  def src
    @type.new.src
  end

end

class InTool < GateTool
  def initialize
    @name = "an entry"
    @type = In
  end
end

class OutTool < GateTool
  def initialize
    @name = "an exit"
    @type = Out
  end
end

class ResetBootsTool < Tool
  def initialize
  end

  def src
    "../editor/img/reset_boots.png"
  end
  def act(editor, i,j)
    editor.puzzle.remove_boot(i,j)
    editor.update_editor_cell(i,j)
  end

  def record_state(editor, i, j)
    state = super(editor, i,j)
    puts "CHecking for boots : #{editor.puzzle.boot_at?(i,j)}"
    if (editor.puzzle.boot_at?(i,j))
      state[:boots_type] = editor.puzzle.boot_at(i,j).class
    end
    state
  end

  def undo!(state, editor)
    puts "Undoing reset boot tool with state #{state}"
    boot_class = state[:boots_type]
    if (boot_class != nil)
      i,j = state[:old_i], state[:old_j]
      editor.puzzle.boot(i,j, boot_class)
      editor.update_editor_cell(i,j)
    end
  end

end

class NameCellTool < Tool

  Icon = "../editor/img/named_cell_0.png"
  Icons = (0..5).collect do |i|
    "../editor/img/named_cell_#{i}.png"
  end

  def initialize
  end

  def src
    Icon
  end

  def act(editor, i, j)
    editor.add_named_cell(i,j)
  end

  def undo!(state, editor)
    # TODO
  end
  
end

class Command

  attr_reader :tool

  def initialize(tool, editor, i,j)
    @tool = tool
    @old_state = tool.record_state(editor, i,j)
    @old_editor = editor
  end

  def to_s
    "Command #{@tool}, #{@old_state}"
  end
  
  def undo!
    @tool.undo!(@old_state, @old_editor)
  end
end

class ToolStack

  def initialize
    @commands = []
  end

  def command!(tool, editor, i, j)
    @commands.push(Command.new(tool, editor, i, j))
    tool.act(editor, i,j)
    puts "After command : State of the command stack #{@commands}"
  end

  def undo!
    if (!empty?)
      to_undo = @commands.pop
      to_undo.undo!
      puts "After undo : State of the command stack #{@commands}"
    end
  end

  def empty?
    @commands.empty?
  end

end
