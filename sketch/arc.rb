require_relative 'command'

class Arc < Command
  def initialize(x, y)
    @x = x
    @y = y
  end

  def to_gcode(tool)
    #sprintf("%s\nG01 X#{FMT} Y#{FMT}", tool.off, @x, @y)
  end

  def to_prawn

  end
end
