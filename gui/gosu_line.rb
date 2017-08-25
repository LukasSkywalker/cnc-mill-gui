require_relative 'gosu_composition'
require_relative 'point'

class GosuLine < GosuComposition
  def initialize(center_point)
    super('Line',center_point, Point.new(0,0))
    @points = []
    @last_modified = Time.new(0)
  end

  def get_active_points
    get_instance_points().concat(@points)
  end

  def get_instance_points
    [@scale_point,@center].reject(&:nil?)
  end

  def add(point)
    @points << point
  end

  def update(x,y)
    return unless @draw
    update_deleted()
    update_shift()
    finish() if @points.last && @points.last.double_clicked
    if @points.length > 0
      ppair = active?() ? @points.zip([*@points[1..-1],Point.new(x,y)]) : @points[0..-2].zip(@points[1..-1])
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