require_relative 'gosu_object'
require_relative 'point'
require_relative '../sketch/line_to'

class Line < GosuObject
  def initialize
    super('Line',0,0,0,0)
    @start = nil
    @end = nil
  end

  def init_start(point)
    @start = point
  end

  def init_end(point)
    @end = point
  end

  def update(x,y)
    if @start && @end
      Gosu.draw_line(@start.x,@start.y,Gosu::Color::GREEN,@end.x,@end.y, Gosu::Color::GREEN)
    elsif @start
      Gosu.draw_line(@start.x,@start.y,Gosu::Color::GREEN,x,y, Gosu::Color::GREEN)      
    end
  end
end