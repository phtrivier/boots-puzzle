# Boots Puzzle - plugin_manager.rb
#
# Plugin Manager
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

require 'plugin_manager'
require 'mocha'

class PluginManagerTest < Test::Unit::TestCase

  def bad(msg)
    assert false, msg
  end

  def setup
    @pm = PluginManager.new
  end

  def test_knows_manifested_plugins
    @pm.manifest!("toto")
    assert @pm.manifested?("toto")
    assert !@pm.loaded?("toto")
    begin
      @pm.manifest!("toto")
      bad("Should not be possible to manifest a plugin twice")
    rescue PluginError => e
      assert_equal("Attempt to manifest plugin toto twice", e.message)
    end
  end

  # TODO : might need to chang ethis (and try and manifest things if necessary...)
  def test_refuses_to_load_unmanifested
    begin
      @pm.load!("tata")
      bad("Should not be possible to load unmanifested")
    rescue PluginError => e
      assert_equal("Attempt to load unmanifested plugin tata", e.message)
    end
  end

  def test_loads_dependencies_recursively
    # We redefine load_plugin_elements, to simply note
    # Who is loaded
    @pm.meta.instance_eval do
      define_method(:load_plugin_elements) do |name|
#       puts "loading elements of #{name}"
      end
    end

    @pm.manifest!("tutu")
    @pm.manifest!("toto", ["tata", "tutu"])
    @pm.manifest!("tata")

    @pm.load!("toto")

    assert @pm.loaded?("tata")
    assert @pm.loaded?("tutu")
    assert @pm.loaded?("toto")

  end

  def test_refuses_to_load_circularly
    @pm.manifest!("toto", ["tata", "tutu"])
    @pm.manifest!("tutu", ["titi"])
    @pm.manifest!("titi", ["toto"])
    @pm.manifest!("tata")

    begin
      @pm.load!("toto")
      bad("Should not be possible to load things circularly dependent")
    rescue PluginError => e
      assert_equal "Can not load plugin toto because of circular dependencies : toto -> tutu -> titi -> toto.", e.message
    end

  end

  def test_does_nothing_to_load_already_loaded_top_level_plugin
    @pm.manifest!("toto")
    assert @pm.manifested?("toto")
    @pm.load!("toto")
    assert @pm.loaded?("toto")
    @pm.meta.instance_eval do
      define_method(:load_plugin_elements) do |p|
        raise RuntimeError.new("Should not have tried to re-load toto's elements")
      end
    end
    @pm.load!("toto")
  end

  def test_does_nothing_to_load_already_loaded_dependency_plugin
    @pm.manifest!("toto", ["tutu"])
    @pm.manifest!("tutu")

    @pm.load!("tutu")
    assert @pm.loaded?("tutu")

    @pm.meta.instance_eval do
      define_method(:load_plugin_elements) do |p|
        if (p.name != "toto")
          raise RuntimeError.new("Already loaded plugin #{p.name} should not have been loaded.")
        end
      end
    end

    @pm.load!("toto")
    assert @pm.loaded?("toto")
  end

  def test_loads_dependencies_using_the_file_loaded

    file_loader = mock()

    Plugin::ElementTypes.each do |type|
      file_loader.expects(:has_element?).with("toto", type).returns(true)
      file_loader.expects(:load_element).with("toto", type)
    end

    @pm.loader = file_loader
    @pm.manifest!("toto")
    assert !@pm.loaded?("toto")
    @pm.load!("toto")
    assert @pm.loaded?("toto")

  end
end
