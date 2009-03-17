# I don't like this ... this puts things all over the place...

require 'naming'

class ToolsRegistry
  @@registered_cell_tools_class = []

  @@registered_boots_tools_class = []
  def self.registered_cell_tools
    @@registered_cell_tools_class
  end

  def self.register_cell_tools(klass)
    if (!@@registered_cell_tools_class.member?(klass))
      @@registered_cell_tools_class << klass
    end
  end

  def self.registered_boots_tools
    @@registered_boots_tools_class
  end

  def self.register_boots_tools(klass)
    if (!@@registered_boots_tools_class.member?(klass))
      @@registered_boots_tools_class << klass
    end
  end


end

# Parent class for all tools
class Tool < Struct.new(:name, :type)
  def initialize(name, type)
    @name = name
    @type = type
  end

  def record_state(editor, i, j)
    state = {}
    state[:old_i] = i
    state[:old_j] = j
    state
  end

  def undo!(state, editor)
  end
end

# Tools that modify the type of a cell
class CellTool < Tool
  def initialize(type)
    @type = type
  end

  def src
    @type.new.src
  end

  def record_state(editor, i, j)
    state = super(editor, i,j)
    state[:old_type] = editor.editor_cell_type(i,j)
    state
  end

  def act(editor, i,j)
    standard_act(editor, i, j)
  end

  def standard_act(editor, i, j)
    begin
      editor.change_editor_cell(i,j,@type)
    rescue CellError => e
      alert(e.message)
    end
  end

  def undo!(state, editor)
    i,j = state[:old_i], state[:old_j]
    editor.change_editor_cell(i,j, state[:old_type])
  end

  # Defines and register a cell tool for
  # a type fof cell
  # arg : plugin name, or cell class
  # extra_act : what to be done after the type of the cell
  #  has been changed by the tool
  def self.for(arg, &extra_act)

    cell_class = nil
    tool_class_name = nil
    if (arg.is_a? Class)
      cell_class = arg
      tool_class_name = cell_class.name + "Tool"
    else
      # TODO Factor in Cell ?
      plugin_name = arg
      tool_class_name = Naming.to_camel_case(plugin_name) + "CellTool"
      cell_class_name = Naming.to_camel_case(plugin_name) + "Cell"
      cell_class = Kernel.const_get(cell_class_name)
    end

    tool_class = Class.new(CellTool)

    tool_class.instance_eval do
      define_method(:initialize) do
        @type = cell_class
      end
    end

    if (block_given?)
      tool_class.instance_eval do
        define_method(:act) do |editor, i, j|
          standard_act(editor, i, j)
          extra_act.call(editor,i,j)
        end
      end
    end

    Kernel.const_set(tool_class_name, tool_class)

    ToolsRegistry.register_cell_tools(tool_class)

  end

end

# Tools that put a pair of boots on a cell
class BootsTool < Tool
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

  def undo!(state, editor)
    i,j = state[:old_i], state[:old_j]
    editor.puzzle.remove_boot(i,j)
    editor.update_editor_cell(i,j)
  end

  # Class function to define boots tool more easily
  def self.for(klass)

    tools_class_name = klass.name + "Tool"
    tools_class = Class.new(BootsTool)
    tools_class.instance_eval do
      define_method :initialize do
        super(klass)
      end
    end

    Kernel.const_set(tools_class_name, tools_class)
    ToolsRegistry.register_boots_tools(tools_class)
  end

end


