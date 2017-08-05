require_relative 'command'

class Positioning < Command
  def initialize(x, y)
    @x = x
    @y = y
  end

  def to_gcode(tool)
    tool.update_position(@x, @y)
    [tool.off, sprintf("G01 X#{FMT} Y#{FMT}", @x, @y)]
  end

  def to_prawn(tool, pdf)
    pdf.text "POS #{@x} #{@y}"
    pdf.stroke_color 'cccccc'
    pdf.line [tool.status.position.first, tool.status.position.last], [@x, @y]
    pdf.stroke
    tool.update_position(@x, @y)
  end
end
