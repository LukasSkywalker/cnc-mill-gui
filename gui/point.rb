require_relative 'gosu_object'

class Point < GosuObject
  attr_reader :x, :y, :modified

  SIZE = 10

  def initialize(x, y, color=Gosu::Color::BLUE)
    super('Point',*get_border(x,y))
    set_pos(x,y)
    @color = color
  end

  def set_color(color)
    @color = color
  end

  def set_pos(x,y)
    @x = x
    @y = y
    @left,@bottom,@right,@top = get_border()
    @modified = Time.now
  end

  def get_border(x=@x,y=@y)
    [x-SIZE,y-SIZE,x+SIZE,y+SIZE]
  end

  def update(x,y)
    if active?
      set_pos(x,y)
    end
    draw
  end

  def draw
    Gosu.draw_rect(@x-SIZE,@y-SIZE, 2*SIZE,2*SIZE, @color)
  end

  def to_a
    [x,y]
  end

  def ==(other)
    @x==other.x && @y==other.y
  end

  def <=>(other)
    @modified <=> other.modified
  end
  
  def >(other)
    @modified > other.modified
  end
  
  def <(other)
    @modified < other.modified
  end

  def -(other)
    Point.new(@x-other.x,@y-other.y)    
  end

  def +(other)
    Point.new(@x+other.x,@y+other.y)
  end

  def shift(x,y)
    @x += x
    @y += y
  end

  def *(scalar)
    raise 'must be a scalar' unless scalar.is_a?(Numeric)
    @x *= scalar
    @y *= scalar
    self
  end

  def /(scalar)
    raise 'must be a scalar' unless scalar.is_a?(Numeric)
    @x /= scalar
    @y /= scalar
    self
  end

  def norm
    Math.sqrt(@x*@x+@y*@y)
  end

  def normalize
    n = norm
    Point.new(@x/n,@y/n)
  end

  def normalize!
    n = norm
    @x /= n
    @y /= n
    self
  end

  def dot(other)
    @x*other.x + @y*other.y
  end

  def scale(scalar)
    n normalize
    n=n*scalar
    n
  end

  def scale!(scalar)
    normalize!
    res = self*(scalar)
    res
  end

  def angle_between(other)
    a_1 = Math.atan2(@y, @x)
    a_2 = Math.atan2(other.y, other.x)
    diff = a_2 - a_1
    if diff < -Math::PI
        diff = Math::PI-(diff.abs-Math::PI)
    elsif diff > Math::PI
      diff = -Math::PI+(diff.abs-Math::PI)
    end
    diff % (2*Math::PI)
  end

  def angle_offset
    angle_between(Point.new(1.0,0.0))
  end

  def sign(num)
    return -1 if num<0 
    1
  end

  def rot(other, angle)
    v = (self-other)
    cos = Math.cos(angle)
    sin = Math.sin(angle)
    p = Point.new(v.x*cos+v.y*sin,-v.x*sin + v.y*cos)
    p+other
  end

end