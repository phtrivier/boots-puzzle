# Boots Puzzle - plugins_test.rb
#
# Test for the globally accessible interface to a plugin manager
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

require 'plugins'
require 'bp_test_case'

class PluginsTest < BPTestCase

  def setup
    Plugins.init("src/test/testdir/plugins_test/plugins")
  end

  def test_can_load_manifest_file_for_a_plugin
    Plugins.read_manifests!
    assert Plugins.manifested?("b")
    assert Plugins.manifested?("c")
  end

  def test_loads_plugin_if_needed
    Plugins.read_manifests!
    assert Plugins.manifested?("b")
    assert Plugins.manifested?("c")
    Plugins.need("b")
    assert Plugins.loaded?("b")
  end

  def test_recursively_loads_plugin_if_needed
    Plugins.read_manifests!
    assert Plugins.manifested?("b")
    assert Plugins.manifested?("c")
    Plugins.need("c")
    assert Plugins.loaded?("b")
    assert Plugins.loaded?("c")
  end

  def test_unneed_plugin_is_not_loaded
    Plugins.read_manifests!
    # "d" is not required by any one
    assert Plugins.manifested?("d")
    Plugins.need("c")
    assert !Plugins.loaded?("d")

    c = CBoots.new
    assert_not_nil c
    assert_equal [3, 3] , c.new_position(nil, nil)

    begin
      d = DBoots.new
      bad "Should not be possible to create something that has not been loaded"
    rescue NameError => e
      assert_equal "uninitialized constant PluginsTest::DBoots", e.message
    end

  end

  def test_sloppyness_forgiving_message
    Plugins.read_manifests!
    begin
      Plugin.manifest("toto")
      bad("No such method")
    rescue RuntimeError => e
      assert_equal "Manifest syntax error for plugin toto : use Plugins.manifest (with an 's') instead of Plugin.manifest in toto/manifest.rb.", e.message
    end

  end

  # Test needing several at a time
  def test_needing_several_plugins_without_array
    Plugins.read_manifests!
    Plugins.need("b", "c")
    assert Plugins.loaded?("b")
    assert Plugins.loaded?("c")
  end

  def test_needing_several_plugins_with_array
    Plugins.read_manifests!
    Plugins.need(["b", "c"])
    assert Plugins.loaded?("b")
    assert Plugins.loaded?("c")
  end

  def test_can_load_manifests_file_from_different_places
    Plugins.add_root("src/test/testdir/plugins_test/extra_dir/plugins")
    Plugins.read_manifests!
    assert Plugins.manifested?("foobar")
  end

end
