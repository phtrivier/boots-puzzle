# TODO : Make it easier to define this in a
# shorter way
class PalmsTool < BootsTool
  def initialize
    super(Palms)
  end
end
ToolsRegistry.register_boots_tools(PalmsTool)
