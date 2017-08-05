require 'ostruct'

class Sketch
  def initialize(tool)
    @tool = tool
    @commands = []
  end

  def <<(command)
    @commands << command
  end

  def debug
    commands = @commands.reduce([]) { |a,c| a.concat(Array(c.to_gcode(@tool)))}
    commands.flatten.reject(&:empty?).compact.inspect
  end

  def run
    #@commands.map(&:to_gcode(@tool))
  end

  def simulate
    #@commands.map(&:to_prawn)
  end

  def print
    File.write('output.gcode', @commands.map(&:to_s).join("\n"))
  end
end

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

class Positioning < Command
  def initialize(x, y)
    @x = x
    @y = y
  end

  def to_gcode(tool)
    [tool.off, sprintf("G01 X#{FMT} Y#{FMT}", @x, @y)]
  end

  def to_prawn

  end
end

class LineTo < Command
  def initialize(x, y)
    @x = x
    @y = y
  end

  def to_gcode(tool)
    [tool.on, sprintf("G01 X#{FMT} Y#{FMT}", @x, @y)]
  end

  def to_prawn

  end
end

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

class Status
  def initialize(val)
    @val = val
  end

  def set(key, val)
    old_val = @val[key]
    @val[key] = val
    old_val != val
  end

  def on!
    set(:on, true)
  end

  def off!
    set(:on, false)
  end

  def <<(val)
    @val.merge(val)
  end

  def method_missing(m, *args, &block)
    if m.to_s.end_with?('=')
      @val[m.to_s.gsub('=', '').to_sym] = args.first
    else
      @val[m]
    end
  end
end

class Tool
  VERTICAL_OFFSET = 3
  attr_reader :status
  
  def initialize
    @status = Status.new(on: false)
  end

  def on

  end

  def off
  
  end
end

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


s = Sketch.new(Laser.new)
s << Positioning.new(10, 10)
s << LineTo.new(20, 20)
s << LineTo.new(30, 30)
s << Positioning.new(0, 0)
#s << Arc.new(1,2,3,4,5)
puts s.debug
