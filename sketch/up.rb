require_relative 'command'

class Up < Command
  def initialize(z, is_relative = false)
    @z = z
    @is_relative = is_relative
  end

  def to_gcode(tool)
    [tool.off, sprintf("G01 Z#{FMT}", @z)]
  end

  def to_prawn(tool, pdf)
    pdf.stroke_color '000000'
    #pdf.circle(tool.status.position, [x, y])
    pdf.stroke
  end
end
