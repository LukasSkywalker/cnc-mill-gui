require_relative 'command'
require 'beziercurve'

class Polygon < Command

  PRECISION = 1

  def initialize(*control_points)
    @polygon = Bezier::Curve.new(*control_points)
  end

  def to_gcode(tool)
    bezier_points = get_bezier_points
    tool.update_position(*bezier_points.last)
    bezier_points.map{|p| sprintf("G01 X#{FMT} Y#{FMT}",*p)}.join("\n")
  end

  def to_prawn(tool, pdf)
    bezier_points = get_bezier_points
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

  def get_bezier_points
    df = @polygon.controlpoints.last.to_a.zip(@polygon.controlpoints.first.to_a).map{|v1,v2| v1-v2}
    dist = Math.sqrt(df.reduce(0){|n,v| n + v**2})
    bezier_points = []
    (0..1).step(PRECISION/dist.to_f).each do |p|
      bezier_points << @polygon.point_on_curve(p).to_a
    end
    bezier_points << @polygon.controlpoints.last.to_a
    bezier_points
  end

end
