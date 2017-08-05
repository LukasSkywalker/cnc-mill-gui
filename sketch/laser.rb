require_relative 'tool'

class Laser < Tool
  def initialize(power: 1000)
    super()
    set_power(power)
  end

  def set_power(power)
    @status.power = power
    @status.power_changed = true
  end

  def on
    commands = []
    if @status.power_changed
      @status.power_changed = false
      commands << "S#{@status.power}"
    end
    commands << (@status.on! ? "M3" : "")
  end

  def off
    @status.off! ? "M5" : ""
  end
end