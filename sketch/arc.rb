require_relative 'command'

class Arc < Command
  attr_reader :end_point

  CLOCKWISE = 'G02'
  COUNTER_CLOCKWISE = 'G03'

  PRECISION_RAD = 1 / 180.0 * Math::PI

  def initialize(center=[0,0], angle= 360, dir= CLOCKWISE, is_relative = false)
    @center = center
    @is_relative = is_relative
    @angle = angle/180.0*Math::PI
    @dir = dir
  end

  def get_end_point(start_point)
    cos = Math.cos(@angle)
    sin = Math.sin(@angle)
    x,y = get_relative_center(start_point)
    if @dir==CLOCKWISE
      pos_offset = [cos*x+sin*y, cos*y-sin*x]
    elsif @dir==COUNTER_CLOCKWISE
      pos_offset = [cos*x-sin*y, cos*y+sin*x]
    end
    pos_offset.zip(get_absolute_center(start_point)).map{ |v1,v2| v2-v1 }
  end

  def to_gcode(tool)
    rel_center = get_relative_center(tool.status.position)
    end_point = get_end_point(tool.status.position)
    tool.update_position(*end_point)
    [tool.on, sprintf("%s X#{FMT}Y#{FMT} I#{FMT}J#{FMT}",@dir,*end_point,*rel_center)]
  end

  def to_prawn(tool,pdf)
    # pdf.text "ARC #{@center} #{@is_relative} #{@angle} #{@dir}"
    end_point = get_end_point(tool.status.position)
    pos = tool.status.position
    abs_center = get_absolute_center(pos)
    radius = Arc.vec_norm(get_relative_center(pos))
    pdf.stroke do
      pdf.move_to(*pos)
      pdf.stroke_color '0000ff'
      angle_offset = Arc.get_angle_offset(get_relative_center(pos))
      (0..@angle).step(PRECISION_RAD) do |d|
        d = @dir==CLOCKWISE ? angle_offset-d : angle_offset+d
        cos = radius*Math.cos(d)
        sin = radius*Math.sin(d)
        pos = Arc.vec_add(abs_center,[cos,sin])
        pdf.line_to(*pos)
      end
      pdf.line_to(*end_point)
    end
    tool.update_position(*end_point)
  end

  def get_relative_center(position)
    return @center if @is_relative
    Arc.vec_diff(position,@center)
  end

  def get_absolute_center(position)
    return @center.zip(position).map{ |v1,v2| v1+v2 } if @is_relative
    @center
  end

  class << self
    def get_angle_offset(dir_vec)
      dir_vec = normalized_vec(dir_vec)
      offset = sign(dir_vec[1])*Math.acos(dir_vec[0])
      offset+Math::PI
    end

    def sign(num)
      return -1 if num<0 
      1
    end

    def normalized_vec(vec)
      len = vec_norm(vec)
      vec.map{ |v| v/len }
    end

    def vec_norm(vec)
      Math.sqrt(vec.reduce(0){ |n,v| n+v**2 })
    end

    def vec_diff(v1,v2)
      [v1[0]-v2[0],v1[1]-v2[1]]
    end

    def vec_add(v1,v2)
      [v1[0]+v2[0],v1[1]+v2[1]]
    end

    def angle_between(v1,v2)
      v1 = Arc.normalized_vec(v1)
      v2 = Arc.normalized_vec(v2)
      Math::acos(dot(v1,v2))
    end

    def dot(v1,v2)
      (v1[0]*v2[0]) + (v1[1]*v2[1])
    end

  end

end
