# Boots Puzzle - action.rb
#
# Actions for gosu-based gui
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


# Actions for the game UI

# Subclasses should define :
# triggered? when the action should be activated
# released? when the action is done and should be considered finished
# act! what to do
class Action

  def initialize(w)
    @w = w
    @key_down = false
  end

  def evaluate(pressed_key)
    if (triggered?(pressed_key))
      act!
    end
  end

end

class SingleKeyAction < Action
  def initialize(w, key)
    super(w)
    @k = key
  end

  def triggered?(pressed_key)
    pressed_key == @k
  end
end

class QuitAction < SingleKeyAction
  def act!
    @w.quit
  end
end

class NextBootsAction < SingleKeyAction
  def act!
    @w.puzzle.player.next_boots!
  end
end

class MoveAction < SingleKeyAction
  def initialize(w, k, dir)
    super(w,k)
    @dir = dir
  end

  def act!
    @w.puzzle.try_move!(@dir)
  end
end

class PickBootsAction < SingleKeyAction
  def act!
    @w.puzzle.try_pick!
  end
end

class DropBootsAction < SingleKeyAction
  def act!
    @w.puzzle.try_drop!
  end
end

class ToggleHintAction < SingleKeyAction
  def act!
    @w.toggle_hint!
  end
end

class HelpAction < SingleKeyAction
  def act!
    @w.show_controls!
  end
end

class ReloadAction < SingleKeyAction
  def act!
    @w.reload_current_puzzle!
  end
end
