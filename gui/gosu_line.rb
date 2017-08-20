require_relative 'gosu_object'
require_relative 'point'

class GosuLine < GosuObject
  def initialize(center_point,scale_point)
    super('Line',0,0,0,0)
    @points = []
    @center = center_point
    @last_center = Point.new(0,0)
    @scale_point = scale_point
    @last_modified = Time.new(0)
  end

  def add(point)
    @points << point
  end

  def update(x,y)
    update_deleted()
    update_shift()
    finish() if @points.last && @points.last.double_clicked
    if @points.length > 0
      ppair = finished? ? @points[0..-2].zip(@points[1..-1]) : @points.zip([*@points[1..-1],Point.new(x,y)])
      ppair.each do |start,ende|
        Gosu.draw_line(start.x,start.y,Gosu::Color::GREEN,ende.x,ende.y, Gosu::Color::GREEN)
      end
    end
  end

  def update_shift
    last_updated = @points.reduce(Time.new(0)){|memo,p| memo = p.modified > memo ? p.modified : memo }
    if last_updated > @last_modified
      @last_modified = last_updated
      new_pos = @points.reduce(Point.new(0,0)){|memo,obj| memo += obj}/@points.length.to_f
      @center.set_pos(*new_pos.to_a)
    else
      shift = (@center - @last_center).to_a
      @points.each do |p|
        p.shift(*shift)
      end
      @scale_point.shift(*shift)
    end
    @last_center.set_pos(*@center.to_a)
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