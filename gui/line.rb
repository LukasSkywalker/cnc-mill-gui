require_relative 'gosu_object'
require_relative 'point'

class Line < GosuObject
  def initialize
    super('Line',0,0,0,0)
    @points = []
  end

  def add(point)
    @points << point
  end

  def update(x,y)
    update_deleted()
    if @points.length > 0
      ppair = finished? ? @points[0..-2].zip(@points[1..-1]) : @points.zip([*@points[1..-1],Point.new(x,y)])
      ppair.each do |start,ende|
        Gosu.draw_line(start.x,start.y,Gosu::Color::GREEN,ende.x,ende.y, Gosu::Color::GREEN)
      end
    end
  end
  
  def update_deleted
    to_del=[]
    @points.each do |p|
      to_del<<p if p.delete?
    end
    to_del.each do |p|
      @points.delete(p)
    end
  end
end