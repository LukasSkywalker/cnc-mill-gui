require_relative 'command'
require 'beziercurve'

class Polygon < Command

  PRECISION = 1

  def initialize(*control_points)
    super()
    if bool?(control_points.last)
      @is_relative = control_points.last
      control_points.delete_at(control_points.length-1)
    end
    @control_points = control_points
  end

  def bool?(value)
    return value.is_a?(TrueClass)||value.is_a?(FalseClass)
  end

  def to_gcode(tool)
    bezier_points = get_bezier_points(get_absolute_controlpoints(tool))
    tool.update_position(*bezier_points.last)
    [tool.on] + bezier_points.map{|p| sprintf("G01 X#{FMT} Y#{FMT}",*p)}
  end

  def to_prawn(tool, pdf)
    bezier_points = get_bezier_points(get_absolute_controlpoints(tool))
    pdf.stroke do
      pdf.move_to(*bezier_points.first)
      pdf.stroke_color '00ff00'
      bezier_points.each do |point|
        pdf.line_to(*point)
      end
      pdf.stroke
    end
    tool.update_position(*bezier_points.last)
  end

  def get_bezier_points(control_points)
    polygon = Bezier::Curve.new(*control_points)
    dist = get_path_length(control_points)
    bezier_points = []
    (0..1).step(PRECISION/dist.to_f).each do |p|
      bezier_points << polygon.point_on_curve(p).to_a
    end
    bezier_points << polygon.controlpoints.last.to_a
    bezier_points
  end

  def get_absolute_controlpoints(tool)
    @control_points.insert(0,tool.status.position) if !@is_relative && @control_points.first !=tool.status.position
    @control_points.insert(0,[0.0,0.0]) if @is_relative && @control_points.first !=[0,0]
    return @control_points.map{|xd,yd| [xd+tool.status.position.first, yd+tool.status.position.last]} if @is_relative
    @control_points
  end

  def get_path_length(bezier_points)
    length = 0
    last = bezier_points.first
    bezier_points.each do |p|
      length += Math.sqrt(last.zip(p).map{|v1,v2| v1-v2 }.reduce(0){|n,v| n + v*v})
      last = p
    end
    length
  end

end
