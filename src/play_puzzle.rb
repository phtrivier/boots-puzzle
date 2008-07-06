begin
  # In case you use Gosu via RubyGems.
  require 'rubygems'
rescue LoadError
  # In case you don't.
end

require 'gosu'

module ZOrder
  Background, Stars, Player, UI = *0..3
end

require 'puzzle'

class SimplePuzzle < Puzzle
  dim 3,3
  row "###"
  row "I##"
  row "--O"
end

class GameWindow < Gosu::Window
  def initialize
    super(640, 480, false)
    self.caption = "Puzzle Game"

    @puzzle = SimplePuzzle.new
    @puzzle.enters_player!

#    @background_image = Gosu::Image.new(self, "media/Space.png", true)

#    @player = Player.new(self)
#    @player.warp(320, 240)

#    @star_anim = Gosu::Image::load_tiles(self, "media/Star.png", 25, 25, false)
#    @stars = Array.new

    @font = Gosu::Font.new(self, Gosu::default_font_name, 20)


    @colors = { Wall => Gosu::Color.new(0xff00ff00),
      Walkable => Gosu::Color.new(0xffff0000),
      In => Gosu::Color.new(0xff000000),
      Out => Gosu::Color.new(0xff0000ff) }

  end

  def update

    if button_down? Gosu::Button::KbLeft or button_down? Gosu::Button::GpLeft then
      @puzzle.try_move!(:left)
    end
    if button_down? Gosu::Button::KbUp or button_down? Gosu::Button::GpUp then
      @puzzle.try_move!(:up)
    end
    if button_down? Gosu::Button::KbDown or button_down? Gosu::Button::GpDown then
      @puzzle.try_move!(:down)
    end
    if button_down? Gosu::Button::KbRight or button_down? Gosu::Button::GpRight then
      @puzzle.try_move!(:right)
    end

  end

  def draw
    @font.draw("Hello world !", 10, 10, ZOrder::UI, 1.0, 1.0, 0xffffff00)
    draw_puzzle
  end

  def draw_puzzle

    @x0 = 20
    @y0 = 50
    @s = 30

    @puzzle.each_cell do |i,j,c|
      draw_cell(i,j,c)
    end

    draw_player

  end

  def draw_player
    i,j = @puzzle.player.pos

    ps = @s / 3
    delta_ps = @s / 3

    x = @x0 + j * @s + delta_ps
    y = @y0 + i * @s + delta_ps

    color = Gosu::Color.new(0xff00ffff)

    draw_quad( x , y , color,
                  x + ps, y, color,
                  x, y + ps, color,
                  x + ps, y+ ps, color,
                  ZOrder::UI)

  end

  def draw_cell(i,j,c)

      x = @x0 + j * @s
      y = @y0 + i * @s

      # TODO : GET THE COLOR
      #color = get_color(c.color_name)
      color = get_color(c)

      # DRAW A SQUARE OF THE COLOR, OF THE PROPER SIZE, ETC...
#      drawQuad (double x1, double y1, Color c1, double x2, double y2, Color c2, double x3, double y3, Color c3, double x4, double y4, Color c4, ZPos z, AlphaMode mode=amDefault)
      #puts "Drawing cell : #{i},#{j}, #{c}"

      draw_quad( x, y, color,
                  x + @s, y , color,
                  x, y + @s, color,
                  x + @s, y+ @s, color,
                  ZOrder::UI)

  end

  def get_color(cell)
    # make it use image instead of colors
    res = @colors[cell.class]
    # puts "Using color #{res}, for class #{cell.class}"
    res
  end

  def button_down(id)
    if id == Gosu::Button::KbEscape then
      close
    end
  end

end

w = GameWindow.new
w.show
