require_relative 'command'

class LineTo < Command
  def initialize(x, y)
    @x = x
    @y = y
  end

  def to_gcode(tool)
    tool.update_position(@x, @y)
    [tool.on, sprintf("G01 X#{FMT} Y#{FMT}", @x, @y)]
  end

  def to_prawn(tool, pdf)
    pdf.text "LINE #{@x} #{@y}"
    pdf.stroke_color '000000'
    pdf.line [tool.status.position.first, tool.status.position.last], [@x, @y]
    pdf.stroke
    tool.update_position(@x, @y)
  end
end
