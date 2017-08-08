require 'prawn'
require_relative '../serial'

def require_all(except)
  Dir.glob('*.rb').reject{|f| f == except }.each { |f| require_relative f }
end

class Sketch
  MAX_WIDTH = 280
  MAX_HEIGHT = 180

  UNIT_MM = "G21"

  def initialize(tool)
    @tool = tool
    @commands = []
  end

  def <<(command)
    @commands << command
  end

  def debug
    @tool.reset
    commands = @commands.reduce([]) { |a,c| a.concat(Array(c.to_gcode(@tool)))}
    commands.flatten.reject(&:empty?).compact.join("\n")
  end

  def run
    @tool.reset
    prog = @commands.reduce([]) { |a,c| a.concat(Array(c.to_gcode(@tool)))}.flatten.reject(&:empty?).compact
    run_program([UNIT_MM] + prog)
  end

  def simulate
    @tool.reset
    pdf = Prawn::Document.new(page_layout: :landscape, margin: 0,:page_size => [1.2*MAX_HEIGHT,1.2*MAX_WIDTH])
    height = pdf.bounds.top_left.last - pdf.bounds.bottom_left.last
    width = pdf.bounds.top_right.first - pdf.bounds.top_left.first
    pdf.bounding_box([width / 2, height], width: width / 2, height: height / 2) do
      draw_bounds(pdf)
      pdf.stroke_color '000000'
      pdf.stroke_axis(height: width/2, negative_axes_length: width/2, step_length: 20)
      @commands.each { |c| c.to_prawn(@tool, pdf) }
      pdf.stroke
    end
    pdf.render_file("output.pdf")
  end

  def print
    File.write('output.gcode', @commands.map(&:to_s).join("\n"))
  end

  private

  def draw_bounds(pdf)
    pdf.stroke_color '00ffff'
    pdf.rectangle([-MAX_WIDTH / 2, MAX_HEIGHT / 2], MAX_WIDTH, MAX_HEIGHT)
    pdf.stroke
  end
end
