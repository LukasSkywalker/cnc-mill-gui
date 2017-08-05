require_relative 'command'

class Arc < Command
  attr_reader :end_point

  CLOCKWISE = 'G02'
  COUNTER_CLOCKWISE = 'G03'

  def initialize(center=[0,0], angle= 360, dir= CLOCKWISE)
    @center = center
    @angle = angle/180.0*Math::PI
    @dir = dir
  end

  def get_end_point(start_point)
    cos = Math.cos(@angle)
    sin = Math.sin(@angle)
    x,y = start_point.zip(@center).map{ |v1,v2| v1-v2 }
    if @dir==CLOCKWISE
      pos_offset = [cos*x+sin*y, cos*y-sin*x]
    elsif @dir==COUNTER_CLOCKWISE
      pos_offset = [cos*x-sin*y, cos*y+sin*x]
    end
    pos_offset.zip(@center).map{ |v1,v2| v1+v2 }
  end

  def to_gcode(tool)
    rel_center = @center.zip(tool.status.position).map{ |v1,v2| v1-v2 }
    end_point = get_end_point(tool.status.position)
    puts rel_center.inspect
    tool.update_position(end_point[0],end_point[1])
    sprintf("%s X#{FMT}Y#{FMT} I#{FMT}J#{FMT}",@dir,*end_point,*rel_center)
  end

  def to_prawn(tool)

  end
end
