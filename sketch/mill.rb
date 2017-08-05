require_relative 'tool'

class Mill < Tool
  def initialize
    super
  end

  def on
    @status.on! ? "M3 Z-#{VERTICAL_OFFSET}" : ""
  end

  def off
    @status.off! ? "M5 Z#{VERTICAL_OFFSET}" : ""
  end
end