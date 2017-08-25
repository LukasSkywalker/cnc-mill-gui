require_relative 'gosu_composition'
require_relative 'point'
require_relative '../sketch/polygon'
require 'beziercurve'

class GosuPolygon < GosuComposition
  def initialize(center_point)
    super('Polygon',center_point,Point.new(0,0))
    @control_points = []
    @polygon = nil
    @next = :start
  end

  def get_active_points()
    [@start,@stop,@center].reject(&:nil?).concat(@control_points)
  end
  
  def add(control_point)
    return if @finished
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
    return unless @draw
    if active?
      update_deleted()
    end
    update_shift()
    @polygon = Bezier::Curve.new(@start.to_a,*@control_points.map{|p| p.to_a},@end.to_a)
    last = @start.to_a
    (0..1).step(10.0/get_path_length()).each do |p|
      pos = @polygon.point_on_curve(p).to_a
      Gosu.draw_line(*last,Gosu::Color.new(255,255*p,255*(1.0-p),0),*pos, Gosu::Color.new(255,255*p,255*(1.0-p),0))
      last = pos
    end
    if active?
      part = 1.0/(@control_points.length+1)
      @control_points.each_with_index do |p,i|
        col = p.get_color
        Gosu.draw_line(*p.to_a,col,*@polygon.point_on_curve((i+1)*part).to_a, col)
      end
    end
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