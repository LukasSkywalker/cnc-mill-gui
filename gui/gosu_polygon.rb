require_relative 'gosu_composition'
require_relative 'point'
require_relative '../sketch/polygon'
require 'beziercurve'

class GosuPolygon < GosuComposition
  def initialize(center_point, scale_point)
    super('Polygon',center_point, scale_point)
    @points = []
    @polygon = nil
    @next = :start
    @start = @end = nil
  end

  def get_instance_points
    [@start,@end,@center,@scale_point].reject(&:nil?).sort().reverse()
  end

  def click_action(id,pos)
    return unless id == GosuComponent::LEFT
    if active?
      if get_active_points().any?{|p| p.overlay?(*pos)} && @end
        @active_controlpoint = get_active_points().find{|p| p.overlay?(*pos)}
      else
        @active_controlpoint = Point.new(*pos)
        add(@active_controlpoint)
      end
    else
      @shift_mode = true
      @active_controlpoint = get_instance_points().find{|p| p.overlay?(*pos)}
    end
    @last_click_propagation = @active_controlpoint.onclick(id,DOWN,pos) if @active_controlpoint
  end
  
  def add(control_point)
    return if @finished
    case @next
    when :start
      puts 'add start'
      @start = control_point
      @start.color = Gosu::Color::GREEN
      @next = :end
    when :end
      puts 'add end'
      @end = control_point
      @end.color = Gosu::Color::RED
      @next = :control
    when :control
      add_control_point(control_point)
    end
  end

  def add_control_point(control_point)
    @points << control_point
    @polygon = Bezier::Curve.new(@start.to_a,*@points.map{|p| p.to_a},@end.to_a)
    update_color()
  end

  def update_color
    (0..255).step(255.0/(@points.length-1)).each_with_index do |col,i|
      @points[i].color = Gosu::Color.new(255,col,255-col,0)
    end
  end

  def update(x,y)
    return unless @draw
    if !@polygon
      get_active_points().each{|p| p.update(x,y)}
      return
    end
    if active?
      update_deleted()
    end
    update_shift()
    get_active_points().each{|p| p.update(x,y)}
    @polygon = Bezier::Curve.new(@start.to_a,*@points.map{|p| p.to_a},@end.to_a)
    last = @start.to_a
    (0..1).step(10.0/get_path_length()).each do |p|
      pos = @polygon.point_on_curve(p).to_a
      Gosu.draw_line(*last,Gosu::Color.new(255,255*p,255*(1.0-p),0),*pos, Gosu::Color.new(255,255*p,255*(1.0-p),0))
      last = pos
    end
    Gosu.draw_line(*last,@end.color,*@end.to_a, @end.color)
    if active?
      part = 1.0/(@points.length+1)
      @points.each_with_index do |p,i|
        col = p.color
        Gosu.draw_line(*p.to_a,col,*@polygon.point_on_curve((i+1)*part).to_a, col)
      end
    end
  end


  def get_balance_point
    return nil unless @polygon
    start = Point.new(0,0)
    steps = 0
    (0..1).step(10.0/get_path_length()).each do |p|
      start += Point.new(*@polygon.point_on_curve(p).to_a)
      steps += 1
    end
    start/steps
  end

  def get_path_length
    length = 0
    last = @start
    @points.each do |p|
      length += (p-last).norm
      last = p
    end
    length.to_f
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