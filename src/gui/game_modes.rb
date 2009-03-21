# Boots Puzzle - game_modes.rb
#
# Different modes used during the game (splash screen, pause, credits, etc...)
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

class GameMode
  attr_reader :actions, :window

  def initialize(window)
    @window = window
    @actions = {}
  end

  def update(pressed_key)
    actions.each do |name, action|
      action.evaluate(pressed_key)
    end
  end
end

class StartGameAction < SingleKeyAction
  def initialize(w)
    super(w, SDL::Key::SPACE)
  end

  def act!
    @w.enter_game!
  end
end

class SplashScreenMode < GameMode
  def initialize(window)
    super(window)
    @actions = {
      :enter_game => StartGameAction.new(window)
    }
  end

  def draw
    window.draw_splash_screen
  end
end

class EndGameAction < SingleKeyAction
  def initialize(w)
    super(w,SDL::Key::SPACE)
  end

  def act!
    @w.quit
  end
end

class EndScreenMode < GameMode
  def initialize(window)
    super(window)
    @actions = {
      :exit => EndGameAction.new(window)
    }
  end

  def draw
    window.draw_end_screen
  end
end

# TODO : make it simpler to define a single key action ?
class LeaveQuoteAction < SingleKeyAction
  def initialize(window)
    super(window, SDL::Key::RETURN)
  end

  def act!
    @w.leave_quote!
  end
end

# Todo : make it simpler to define a game mode ?
# (map of actions / draw method ?)
class QuoteMode < GameMode
  def initialize(window)
    super(window)
    @actions = {
      :leave => LeaveQuoteAction.new(window)
    }
  end

  def draw
    window.draw_quote
  end
end

class InPlayGameMode < GameMode

  def initialize(window)
    super(window)
    @actions = {
      :quit => QuitAction.new(window, SDL::Key::ESCAPE),
      :next_boots => NextBootsAction.new(window, SDL::Key::SPACE) ,
      :up => MoveAction.new(window, SDL::Key::UP, :up),
      :down => MoveAction.new(window, SDL::Key::DOWN, :down),
      :right => MoveAction.new(window, SDL::Key::RIGHT, :right),
      :left => MoveAction.new(window, SDL::Key::LEFT, :left),
      :drop_boots => DropBootsAction.new(window, SDL::Key::LCTRL),
      :toggle_hint => ToggleHintAction.new(window, SDL::Key::J),
      :show_controls => HelpAction.new(window, SDL::Key::H),
      :reload => ReloadAction.new(window, SDL::Key::R)
    }
  end

  def update(pressed_key)
    super(pressed_key)
    window.check_level_finished
  end

  def draw
    window.draw_puzzle
  end

end
