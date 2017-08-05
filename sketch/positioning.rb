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

  def to_prawn(pdf)
    pdf.text "POSITIONING"
  end
end
