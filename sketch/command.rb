class Command
  attr_reader :is_relative

  FMT = "%0.5f"
  @@laser = false
  @@inking = true

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
