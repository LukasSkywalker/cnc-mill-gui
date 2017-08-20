require_relative 'gosu_object'
require_relative 'point'
require_relative '../sketch/polygon'
require 'beziercurve'

class GosuPolygon < GosuObject
  def initialize(center_point)
    super('Polygon',0,0,0,0)
    @control_points = []
    @polygon = nil
    @next = :start
    @center = center_point
    @last_center = Point.new(*@center.to_a)
    @last_modified = Time.now
  end


  def add(control_point)
    case @next
    when :start
      @start = control_point
      @start.set_color(Gosu::Color::GREEN)
      @next = :end
    when :end
      @end = control_point
      @end.set_color(Gosu::Color::RED)
      @next = :control
    when :control
      add_control_point(control_point)
    end
  end

  def add_control_point(control_point)
    @control_points << control_point
    @polygon = Bezier::Curve.new(@start.to_a,*@control_points.map{|p| p.to_a},@end.to_a)
    update_color()
  end

  def update_color
    (0..255).step(255.0/(@control_points.length-1)).each_with_index do |col,i|
      @control_points[i].set_color(Gosu::Color.new(255,col,255-col,0))
    end    
  end

  def update(x,y)
    return unless @polygon
    @polygon = Bezier::Curve.new(@start.to_a,*@control_points.map{|p| p.to_a},@end.to_a)
    update_deleted()
    update_shift()
    last = @start.to_a
    (0..1).step(10.0/get_path_length()).each do |p|
      pos = @polygon.point_on_curve(p).to_a
      Gosu.draw_line(*last,Gosu::Color.new(255,255*p,255*(1.0-p),0),*pos, Gosu::Color.new(255,255*p,255*(1.0-p),0))
      last = pos
    end
    part = 1.0/(@control_points.length+1)
    @control_points.each_with_index do |p,i|
      col = p.get_color
      Gosu.draw_line(*p.to_a,col,*@polygon.point_on_curve((i+1)*part).to_a, col)
    end
  end

  def update_shift
    if @start.modified > @last_modified || @end.modified > @last_modified
      @last_modified = @start.modified > @end.modified ? @start.modified : @end.modified
      new_pos = @start + ((@end-@start)/2.0)
      @center.set_pos(*new_pos.to_a)
      puts "update shift"
    else
      shift = (@center - @last_center).to_a
      puts "shift"
      @start.shift(*shift)
      @end.shift(*shift)
      @control_points.each do |p|
        p.shift(*shift)
      end
    end
    @last_center.set_pos(*@center.to_a)
  end

  def get_path_length
    length = 0
    last = @start
    @control_points.each do |p|
      length += (p-last).norm
      last = p
    end
    length.to_f
  end
  
  def update_deleted
    to_del=[]
    @control_points.each do |p|
      to_del<<p if p.delete?
    end
    to_del.each do |p|
      @control_points.delete(p)
    end
  end
end