require_relative 'gosu_composition'
require_relative 'point'
require 'byebug'

class GosuLine < GosuComposition
  def initialize(center_point, scale_point)
    super('Line',center_point, scale_point)
    @scale_point.draw = false
    @points = []
    @last_modified = Time.new(0)
  end

  def click_action(id,pos)
    return unless id == GosuComponent::LEFT
    puts "line: click"
    if active?
      if get_active_points().any?{|p| p.overlay?(*pos)} && @points.length > 0
        @active_controlpoint = get_active_points().find{|p| p.overlay?(*pos)}
      else
        @active_controlpoint = Point.new(*pos)
        add(@active_controlpoint)
      end
    else
      @shift_mode = true
      @active_controlpoint = get_dynamic_points().find{|p| p.overlay?(*pos)}
    end
    @last_click_propagation = @active_controlpoint.onclick(id,DOWN,pos) if @active_controlpoint
  end

  def add(point)
    @points << point
  end

  def update(x,y)
    return unless @draw
    update_deleted()
    update_shift()
    draw(x,y)
    get_active_points().each{|p| p.update(x,y)}
  end


  def finish
    @edit_mode = false
    get_instance_points().each{|p| p.draw = false}
  end

  def draw(x,y)
    return unless @points.length > 0
    ppair = active?() ? @points.zip([*@points[1..-1],Point.new(x,y)]) : @points[0..-2].zip(@points[1..-1])
    ppair.each do |start,ende|
      Gosu.draw_line(start.x,start.y,Gosu::Color::GREEN,ende.x,ende.y, Gosu::Color::GREEN,-1)
    end
  end

  def overlay?(x,y)
    if active?
      get_active_points().any?{|p| p.overlay?(x,y)}
    else
      get_dynamic_points().any?{|p| p.overlay?(x,y)}
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