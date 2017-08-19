require_relative 'gosu_object'
require_relative 'point'
require_relative '../sketch/line_to'

class Line < GosuObject
  def initialize
    super('Line',0,0,0,0)
    @points = []
  end

  def add(point)
    @points << point
  end

  def update(x,y)
    if @points.length > 0
      ppair = @points.length > 1 ? @points.zip(@points) : @points.zip([*@points[1..-1],Point.new(x,y)])
      ppair.each do |start,ende|
        Gosu.draw_line(start.x,start.y,Gosu::Color::GREEN,ende.x,ende.y, Gosu::Color::GREEN)
      end
    end
  end
end