require_relative 'gosu_component'

class Point < GosuComponent
  attr_accessor :color
  attr_reader :x, :y, :modified, :double_clicked

  def initialize(x, y, color=Gosu::Color::BLUE, size = 15.0)
    super('Point',*get_border(x,y,size))
    @size = size
    set_pos(x,y)
    @color = color
    @modified = Time.now
  end

  def set_pos(x,y)
    @x = x
    @y = y
    @left,@bottom,@right,@top = get_border()
    @modified = Time.now
  end

  def get_border(x=@x,y=@y,sz=@size)
    sz2 = sz / 2.0
    [x-sz2,y-sz2,x+sz2,y+sz2]
  end

  def update(x,y)
    set_pos(x,y) if active?
    draw() if @draw
  end

  def draw
    sz2 = @size/2.0
    Gosu.draw_rect(@x-sz2,@y-sz2, @size,@size, @color)
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
    if other.is_a?(Point)
      @modified > other.modified
    else
      @modified > other
    end
  end
  
  def <(other)
    if other.is_a?(Point)
      @modified < other.modified
    else
      @modified < other
    end
  end

  def -(other)
    Point.new(@x-other.x,@y-other.y)    
  end

  def +(other)
    Point.new(@x+other.x,@y+other.y)
  end

  def shift(x,y)
    set_pos(@x+x,@y+y)
  end

  def *(scalar)
    raise 'must be a scalar' unless scalar.is_a?(Numeric)
    set_pos(@x*scalar,@y*scalar)
    self
  end

  def /(scalar)
    raise 'must be a scalar' unless scalar.is_a?(Numeric)
    set_pos(@x/scalar,@y/scalar)
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
    set_pos(@x/n,@y/n)
    self
  end

  def dot(other)
    @x*other.x + @y*other.y
  end

  def scale(scalar)
    norm_point=normalize
    norm_point*scalar
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