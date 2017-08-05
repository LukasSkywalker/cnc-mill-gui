def require_all(except)
  Dir.glob('*.rb').reject{|f| f == except }.each { |f| require_relative f }
end

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
