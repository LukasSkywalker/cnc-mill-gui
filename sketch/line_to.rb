require_relative 'command'

class LineTo < Command
  def initialize(x, y, is_relative = false)
    @x = x
    @y = y
    @is_relative = is_relative
  end

  def to_gcode(tool)
    x,y = get_pos(tool)
    tool.update_position(x, y)
    [tool.on, sprintf("G01 X#{FMT} Y#{FMT}", x, y)]
  end

  def to_prawn(tool, pdf)
    x,y = get_pos(tool)
    pdf.stroke_color '000000'
    pdf.line(tool.status.position, [x, y])
    pdf.stroke
    tool.update_position(x, y)
  end

  def get_pos(tool)
    if @is_relative
      [tool.position.first + @x, tool.position.last + @y]
    else
      [@x, @y]
    end
  end
end
