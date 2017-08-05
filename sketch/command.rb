class Command
  FMT = "%0.5f"
  @@laser = false
  @@inking = true

  def to_gcode(tool)
    raise StandardError, 'Subclasses must implement this'
  end
  def to_prawn
    raise StandardError, 'Subclasses must implement this'
  end
  def to_s(tool)
    self.to_gcode(tool)
  end
end