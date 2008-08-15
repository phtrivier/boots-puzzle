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
class CellTool
  def initialize(type)
    @type = type
  end

  def src
    @type.new.src
  end

  def act(editor, i,j)
    begin
      editor.change_editor_cell(i,j,@type)
    rescue CellError => e
      alert(e.message)
    end
  end
end

# TODO : MAKE A TOOL ONLY FOR IN AND OUT
class GateTool < Struct.new(:name, :type)
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

class BootsTool < Struct.new(:type)
  def initialize(type)
    @type = type
  end

  def src
    @type.new.src
  end

  def act(editor, i,j)
    begin
      editor.puzzle.boot(i,j,@type)
      editor.update_editor_cell(i,j)
    rescue CellError => e
      alert("You cannot put a pair of boots on a non walkable cell")
    end
  end
end

class ResetBootsTool
  def src
    "img/reset_boots.png"
  end
  def act(editor, i,j)
    editor.puzzle.boot(i,j,nil)
    editor.update_editor_cell(i,j)
  end
end

class NameCellTool

  Icon = "img/named_cell.png"

  def src
    Icon
  end

  def act(editor, i, j)
    name = editor.ask("Name of the cell ?")
    editor.puzzle.named_cell(name.to_sym, i,j)
    editor.update_named_cells_list
  end

end
