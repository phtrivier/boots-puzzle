# I don't like this ... this puts things all over the place...

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
