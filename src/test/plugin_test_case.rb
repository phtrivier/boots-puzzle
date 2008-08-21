require 'bp_test_case'

class PluginTestCase < BPTestCase

  def self.tested_plugin(name)

    require 'src/plugins/core/plugins.rb'
    Plugins.init("src/plugins")
    Plugins.read_manifests
    Plugins.need(name.to_s)

  end


end
