require_relative 'command'

class FeedRate < Command
  def initialize(val)
    @val = val
  end

  def to_gcode(tool)
    "F#{@val}"
  end

  def to_prawn(tool, pdf)
    tool.update_position(*tool.status.position)
  end
end
