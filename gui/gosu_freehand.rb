require_relative 'gosu_composition'
require_relative 'point'
require 'byebug'

class GosuFreehand < GosuComposition
  def initialize(center_point, scale_point)
    super('Freehand',center_point, scale_point)
    @scale_point.draw = false
    @points = []
    @last_modified = Time.new(0)
  end

  def click_action(id,pos)
    return unless id == GosuComponent::LEFT
    puts "freehand: click"
    if active?
      if get_active_points().any?{|p| p.overlay?(*pos)} && @points.length > 0
        @active_controlpoint = get_active_points().find{|p| p.overlay?(*pos)}
      else
        @active_controlpoint = Point.new(*pos, Gosu::Color::GREEN)
        add(@active_controlpoint)
      end
    else
      @shift_mode = true
      @active_controlpoint = get_active_points().find{|p| p.overlay?(*pos)}
    end
    @last_click_propagation = @active_controlpoint.onclick(id,DOWN,pos) if @active_controlpoint
  end

  def button_up_action(id,pos)
    add(Point.new(*pos, Gosu::Color::RED))
    finish()
  end

  def get_instance_points
    return [] unless @points.length > 0
    if @points.length > 1
      [@points.first,@points.last]
    else
      [@points.first]
    end
  end

  def get_dynamic_points
    return [] unless @points.length > 2
    @points[1..@points.length-2]
  end

  def add(point)
    @points << point
  end

  def update(x,y)
    return unless @draw
    if active? && @points.length>0
      p = Point.new(x,y, Gosu::Color::GRAY,5)
      if (@points.last-p).norm > 8
        add(p)
      end
    end
    update_deleted()
    update_shift()
    draw(x,y)
    get_active_points().each{|pt| pt.draw()}
  end

  def finish
    @edit_mode = false
    get_instance_points().each{|p| p.draw = false}
  end

  def draw(x,y)
    return unless @points.length > 1
    ppair = @points[0..@points.length-2].zip(@points[1..@points.length-1])
    ppair.each do |start,ende|
      Gosu.draw_line(start.x,start.y,Gosu::Color::GREEN,ende.x,ende.y, Gosu::Color::GREEN,-1)
    end
  end

  def overlay?(x,y)
    if active?
      get_active_points().any?{|p| p.overlay?(x,y)}
    else
      get_active_points().any?{|p| p.overlay?(x,y)}
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