require_relative 'gosu_object'
require_relative 'point'
require_relative '../sketch/arc'

class GosuArc < GosuObject
  def initialize
    super('Arc',0,0,0,0)
    @start=@center=@end=nil
    @deleted = false
    @last_center = nil
  end

  def delete?
    @deleted
  end

  def set(start: nil, radius_control: nil,ende: nil,center: nil)
    puts start.inspect
    puts ende.inspect
    puts center.inspect
    if start
      @start = start
      @start.set_color(Gosu::Color::GREEN)
    end
    if radius_control
      @radius_control = radius_control
      @radius_control.set_color(Gosu::Color::BLUE)
    end
    if ende
      @end = ende
      @end.set_color(Gosu::Color::RED)
    end
    if center
      @center = center
      @center.set_color(Gosu::Color::BLUE)
    end
    # if @start.nil?
    #   @start = point
    #   @radius_control = point
    #   @end = point2
    #   @end.set_color(Gosu::Color::RED)
    # elsif !@center
    #   @center = point
    # end
  end

  def update(x,y)
    return if @start.nil?
    update_deleted()
    angle = 2*Math::PI
    last_pos = Point.new(@start.x,@start.y)
    center = @center.nil? ? Point.new(x,y) : @center
    return if @start==center
    if @start!=@end
      angle = (@start-center).angle_between(@end-center)
      angle = 2*Math::PI - angle if angle < 0
    end
    r = radius(center)
    angle_offset = (@start-center).angle_offset
    (0..angle).step(Arc::PRECISION_RAD) do |d|
      d = d-angle_offset
      cos = r*Math.cos(d)
      sin = r*Math.sin(d)
      pos = (center+Point.new(cos,sin))
      Gosu.draw_line(*last_pos.to_a,Gosu::Color::GREEN,*pos.to_a, Gosu::Color::GREEN)
      last_pos = pos
    end
    puts last_pos.to_a.inspect
    Gosu.draw_line(*last_pos.to_a,Gosu::Color::RED,@end.x,@end.y, Gosu::Color::RED)
    update_control_points(center)
  end
  
  def update_control_points(center)
    return 0 unless center
    update_shift()
    r = radius(center)
    update_radius(center,r)
    update_radius_control(center)
    r
  end
  
  def update_shift
    return unless @center
    @last_center ||= Point.new(*@center.to_a)
    shift = (@center - @last_center).to_a
    @start.shift(*shift)
    @end.shift(*shift)
    @radius_control.shift(*shift)
    @last_center.set_pos(*@center.to_a)
  end

  def radius(center)
    (@radius_control-center).norm
  end

  def update_radius(center,r)
    @start.set_pos(*(center + (@start - center).scale!(r)).to_a)
    @end.set_pos(*(center + (@end - center).scale!(r)).to_a)    
  end

  def update_radius_control(center)
    start_v = @start-center
    a2 = start_v.angle_between(@end-center) / 2.0
    p = @start.rot(center,-a2)
    @radius_control.set_pos(p.x,p.y)
  end
  
  def update_deleted
    [@start,@center,@end].each do |p|
      @deleted = true if p && p.delete?
    end
  end

  def complete?
    @start&&@center
  end
end