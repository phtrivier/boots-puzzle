# Boots Puzzle - player_test.rb
#
# Unit tests for the Player class
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


require 'player'

require 'test/unit'

class PlayerTest < Test::Unit::TestCase

  def setup
    @p = Player.new
  end

  def test_player_has_bare_feer_by_default
    assert_equal(BareFeet, @p.current_boots.class)
    assert_equal(1, @p.boots.size)
  end

   def test_player_can_pick_boots_and_navigate
     assert_equal(1, @p.boots.size)
     b1 = Boots.new
     @p.pick!(b1)
     assert_equal(2, @p.boots.size)
     assert_equal(BareFeet, @p.current_boots.class)
     @p.next_boots!
     assert_equal(2, @p.boots.size)
     assert_equal(b1, @p.current_boots)
     @p.previous_boots!
     assert_equal(2, @p.boots.size)
     assert_equal(BareFeet, @p.current_boots.class)
     @p.previous_boots!
     assert_equal(b1, @p.current_boots)
     @p.next_boots!
     assert_equal(BareFeet, @p.current_boots.class)
   end

   def test_player_can_have_as_much_as_three_boots
     b1 = Boots.new
     b2 = Boots.new
     b3 = Boots.new
     assert @p.can_pick_boots?
     @p.pick!(b1)
     assert @p.can_pick_boots?
     assert_equal 2, @p.boots.size
     @p.pick!(b2)
     assert !@p.can_pick_boots?
     assert_equal 3, @p.boots.size
     @p.pick!(b3)
     assert_equal 3, @p.boots.size

     assert @p.boots.member?(b1)
     assert @p.boots.member?(b2)
     assert !@p.boots.member?(b3)
   end

   def test_player_can_drop_current_boots_but_not_bare_foot
     b1 = Boots.new
     b2 = Boots.new
     bf = @p.current_boots
     @p.pick!(b1)
     @p.pick!(b2)
     @p.next_boots!
     assert_equal b1, @p.current_boots
     @p.drop!
     assert_equal 2, @p.boots.size
     assert !@p.boots.member?(b1)
     assert_equal bf, @p.current_boots
     @p.drop!
     assert_equal 2, @p.boots.size
     assert_equal bf, @p.current_boots
   end

   def test_iterate_with_info

     non_selected = []
     selected = nil
     bf = @p.current_boots
     b1 = Boots.new
     b2 = Boots.new
     @p.pick!(b1)
     @p.pick!(b2)
     @p.next_boots!

     @p.each_boots do |b, current|
       if (current)
         selected = b
       else
         non_selected << b
       end
     end

     assert_equal 2, non_selected.size
     assert non_selected.member?(b2)
     assert non_selected.member?(bf)
     assert_equal b1, selected

   end


end
