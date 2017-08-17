require_relative 'gosu_object'

class Button < GosuObject
  attr_reader :x, :y

  SIZE = [95,30]

  def initialize(window,text, x, y)
    super("Button_#{text.gsub(' ','')}",*get_border(x,y))
    @x = x
    @y = y
    @text = text
    @on = false
    @timer = 0
    @font = Gosu::Font.new(window, Gosu::default_font_name, 24)
  end

  def get_border(x=@x,y=@y)
    [x,y,x+SIZE.first,y+SIZE.last]
  end

  def active?
    @timer > 0
  end

  def update(x,y)
    @timer += 21 if (!@state[LEFT] && @state[CHANGED]==LEFT)
    @timer -= 1 if @timer > 0
    @state[CHANGED] = nil if @state[CHANGED]
    draw
  end

  def delete?
    false
  end

  def draw
    Gosu.draw_rect(@x,@y, SIZE.first,SIZE.last, active? ? Gosu::Color::GREEN : Gosu::Color::RED,-999)
    @font.draw(@text, @x+5,@y+5,1, 1.0, 1.0, Gosu::Color::WHITE)
  end
end