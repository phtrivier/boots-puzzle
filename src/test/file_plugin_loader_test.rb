# Boots Puzzle - file_plugin_loader_test.rb
#
# Test for a plugin Loader using files and directories
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

require 'test/unit'
require 'file_plugin_loader'

class FilePluginLoaderTest < Test::Unit::TestCase

  def setup
    @base = "testdir/file_plugin_loader_test/plugins"
    @l = FilePluginLoader.new("#{@base}")
  end

  def test_inspect_a_plugin_by_its_name
    assert_equal "#{@base}/a", @l.plugin_dir("a")
    assert_equal "#{@base}/a/cells", @l.plugin_elem_dir("a", :cells)
    assert_equal ["#{@base}/a/cells/a_cell.rb"], @l.plugin_element_filenames("a", :cells)

    assert @l.has_element?("a", :cells)
    assert @l.has_element?("a", :boots)
    assert !@l.has_element?("a", :patches)
    assert !@l.has_element?("a", :tools)
  end

  def test_loads_plugin_from_its_name
    @l.load_element("a", :cells)
    assert_not_nil(ACell)
    a = ACell.new
    assert_not_nil(a)

    @l.load_element("a", :boots)
    assert_not_nil(ABoots)
    b = ABoots.new
    assert_not_nil(b)

    assert_equal("../img/toto.png", b.src)

  end

end
