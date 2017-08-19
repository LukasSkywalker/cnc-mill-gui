require_relative 'gosu_object'
require_relative 'point'
require_relative '../sketch/arc'

class GosuArc < GosuObject
  def initialize
    super('Arc',0,0,0,0)
    @start=@center=@end=nil
    @deleted = false
  end

  def delete?
    @deleted
  end

  def add(point,point2=nil)
    if @start.nil?
      @start = point
      @end = point2
    elsif !@center
      @center = point
    end
  end

  def update(x,y)
    return if @start.nil?
    update_deleted()
    angle = 2*Math::PI
    last_pos = [@start.x,@start.y]
    center = @center.nil? ? [x,y] : @center.to_a
    if @start!=@end
      v1=Arc.normalized_vec(Arc.vec_diff(center,@start.to_a))
      v2=Arc.normalized_vec(Arc.vec_diff(center,@end.to_a))
      angle = Arc.angle_between(v1,v2)
      angle = 2*Math::PI - angle if angle < 0
    end
    radius = Arc.vec_norm(Arc.vec_diff(last_pos,center))
    angle_offset = Arc.get_angle_offset(Arc.vec_diff(last_pos,center))
    (0..angle).step(Arc::PRECISION_RAD) do |d|
      d = angle_offset+d
      cos = radius*Math.cos(d)
      sin = radius*Math.sin(d)
      pos = Arc.vec_add(center,[cos,sin])
      Gosu.draw_line(*last_pos,Gosu::Color::GREEN,*pos, Gosu::Color::GREEN)
      last_pos = pos
    end
    Gosu.draw_line(*last_pos,Gosu::Color::GREEN,@end.x,@end.y, Gosu::Color::GREEN)
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