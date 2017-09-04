require_relative 'tool'

class Pen < Tool
  def initialize
    super
  end

  def on
    @status.on! ? "Z-#{VERTICAL_OFFSET}" : ""
  end

  def off
    @status.off! ? "Z-#{VERTICAL_OFFSET}" : ""
  end
end