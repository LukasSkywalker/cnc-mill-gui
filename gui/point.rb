require_relative 'gosu_object'

class Point < GosuObject
  attr_reader :x, :y

  SIZE = 15

  def initialize(x, y)
    super('Point',*get_border(x,y))
    @x = x
    @y = y
  end

  def get_border(x=@x,y=@y)
    [x-SIZE,y-SIZE,x+SIZE,y+SIZE]
  end

  def update(x,y)
    if active?
      @x,@y = x,y
      @left,@bottom,@right,@top = get_border
    end
    draw
  end

  def draw
    Gosu.draw_rect(@x-SIZE,@y-SIZE, 2*SIZE,2*SIZE, Gosu::Color::BLUE)
  end
end