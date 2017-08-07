class Command
  attr_reader :is_relative

  RELATIVE = true
  ABSOLUTE = false

  FMT = "%0.5f"

  def initialize
    @is_relative = false
  end

  def to_gcode(tool)
    raise StandardError, 'Subclasses must implement this'
  end
  def to_prawn(pdf)
    raise StandardError, 'Subclasses must implement this'
  end
  def to_s(tool)
    self.to_gcode(tool)
  end
end
