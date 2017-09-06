require_relative 'gosu_component'

class Point < GosuComponent
  attr_accessor :color, :size, :can_connect
  attr_reader :x, :y,:double_clicked

  COLOR_SNAPPED = Gosu::Color::YELLOW

  def initialize(x, y, color=Gosu::Color::BLUE, size = 15.0)
    super('Point',*get_border(x,y,size))
    @size = size
    set_pos(x,y)
    @color = color
    @connected_point = nil
    @snap_candidate = nil
    @can_connect = true
  end

  def set_size_color(size,color)
    @size=size
    @color=color
  end


  def button_up_action(id,pos)
    super
    return unless @can_connect    
    if @delete_request && @snap_candidate
      disconnect_points()
      @delete_request = false
    end
    if @snap_candidate && distance_to(@snap_candidate) < 2*@size && id == GosuComponent::LEFT
      connect_point(@snap_candidate) if @snap_candidate
    end
  end

  def connect_point(point, insert=true)
    raise 'point has to be a Point' unless point.is_a?(Point)
    return if point.object_id == self.object_id 
    if @connected_point
      p = @connected_point
      @connected_point = point
      point.connect_point(p, false)      
    elsif insert
      @connected_point = point
      point.connect_point(self, false)
    else
      @connected_point = point
    end
  end

  def disconnect_points
    return unless @connected_point
    p = @connected_point
    @connected_point = nil
    p.disconnect_points()
  end

  def update_connected(x,y,initiator=nil)
    return if self.object_id==initiator.object_id
    @connected_point.update_connected(x,y,initiator.nil? ? self : initiator)
    update_pos(x,y)
  end

  def set_snap_candidate(snap_candidate)
    return unless @can_connect
    @snap_candidate = snap_candidate
    set_pos(*snap_candidate.to_a,true)
  end

  def set_pos(x,y, snap=false)
    update_pos(x,y) if !snap_mode? || snap
    update_connected(x,y) if @connected_point
  end

  def snap_mode?
    return false unless @can_connect
    if @snap_candidate
      distance_to(@snap_candidate) < 2*@size
    end
    active? && @state[:ctrl]
  end
 
  private def update_pos(x,y)
    @x = x
    @y = y
    @left,@top,@right,@bottom = get_border()
    @last_modified = Time.now    
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
    Gosu.draw_rect(@x-sz2,@y-sz2, @size,@size, @connected_point ? COLOR_SNAPPED : @color)
  end

  def to_a
    [x,y]
  end

  def ==(other)
    return unless other.is_a?(Point)
    @x==other.x && @y==other.y
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

  def distance_to(point)
    (self-point).norm
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

  def scale_from(center,scalar)
    center + (self-center).scale(scalar)
  end

  def scale_from!(center,scalar)
    set_pos(*scale_from(center,scalar).to_a)
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
    -sign(diff)*(diff % (2*Math::PI))
    # diff % (2*Math::PI)
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

  def rot!(other, angle)
    set_pos(*rot(other,angle).to_a)
  end

end