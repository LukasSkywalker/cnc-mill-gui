require_relative 'command'

class Pause < Command
  def initialize(duration)
    @duration = duration
  end

  def to_gcode(tool)
    "G04 P#{@duration}"
  end

  def to_prawn(tool, pdf)
    pdf.text "PAUSE"
    tool.update_position(*tool.status.position)
  end
end
