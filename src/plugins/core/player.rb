# Boots Puzzle - player.rb
#
# Player in a puzzle
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

require 'boots'
require 'notification'

class Player

  include Notification

  attr_reader :i,:j
  attr_reader :boots

  def initialize
    @boots = [BareFeet.new]
    @current_boots_index = 0
    @listeners = []
  end

  def current_boots
    @boots[@current_boots_index]
  end

  def pick!(boots)
    if (can_pick_boots?)
      @boots << boots
    end
  end

  def next_boots!
    old_index = @current_boots_index
    @current_boots_index = (@current_boots_index + 1) % @boots.size
    if (old_index != @current_boots_index)
      message("You're now wearing #{current_boots.txt}")
    end
  end

  def previous_boots!
    @current_boots_index = (@current_boots_index - 1) % @boots.size
  end

  def can_pick_boots?
    @boots.size < 3
  end

  def drop!
    if (not bare_feet?)
      boots.delete_at(@current_boots_index)
      @current_boots_index = 0
    end
  end

  def each_boots
    @boots.each_with_index do |b,i|
      yield b, (@current_boots_index == i)
    end
  end

  def bare_feet?
    @current_boots_index == 0
  end

  def pos
    [@i, @j]
  end

  def move!(pos)
    @i,@j = pos
  end

end
