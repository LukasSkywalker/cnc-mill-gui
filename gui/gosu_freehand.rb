require_relative 'gosu_composition'
require_relative 'point'
require 'byebug'

class GosuFreehand < GosuComposition
  MIN_POINT_DIFFERENC = 5
  def initialize(center_point, scale_point)
    super('Freehand',center_point, scale_point)
    @scale_point.draw = false
    @points = []
    @last_modified = Time.new(0)
  end

  def click_action(id,pos)
    puts "freehand: click"
    if active?
      if get_active_points().any?{|p| p.overlay?(*pos)} && @points.length > 0
        @active_controlpoint = get_active_points().find{|p| p.overlay?(*pos)}
      elsif id == GosuComponent::LEFT
        @active_controlpoint = Point.new(*pos, Gosu::Color::GREEN)
        add(@active_controlpoint)
      end
    else
      @shift_mode = id == GosuComponent::LEFT
      @active_controlpoint = get_active_points().find{|p| p.overlay?(*pos)}
    end
    @last_click_propagation = @active_controlpoint.onclick(id,DOWN,pos) if !active? && @active_controlpoint
  end

  def button_up_action(id,pos)
    puts "#{self.class}: click off"
    if active? && GosuComponent::LEFT
      add(Point.new(*pos))
      finish()
    end
    @last_click_propagation.onclick(id,UP,pos) if @last_click_propagation    
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
      p = Point.new(x,y)
      if (@points.last-p).norm > MIN_POINT_DIFFERENC
        add(p)
      end
    elsif @state[:ctrl] && pt = @points.find{|point| point.overlay?(x,y)}
      @points.delete(pt)
    end
    changed = update_deleted() || update_shift()
    update_size_color() if changed
    if active?
      get_active_points().each{|point| point.draw}
    else
      get_active_points().each{|point| point.update(x,y)}
    end
    draw(x,y)
  end

  def update_size_color
    @points.first.set_size_color(20,Gosu::Color::GREEN)
    return unless @points.length>1
    @points.last.set_size_color(20,Gosu::Color::RED)
    return unless @points.length>2
    @points[1..@points.length-2].each{|pt| pt.set_size_color(5,Gosu::Color::GRAY)}
  end

  def finish
    @edit_mode = false
  end

  def draw(x,y)
    return unless @points.length > 1
    ppair = @points[0..@points.length-2].zip(@points[1..@points.length-1])
    ppair.each do |start,ende|
      Gosu.draw_line(start.x,start.y,Gosu::Color::GREEN,ende.x,ende.y, Gosu::Color::GREEN,-1)
    end
  end

  def overlay?(x,y)
    get_active_points().any?{|p| p.overlay?(x,y)}
  end
  
  
  def update_deleted
    to_del=[]
    @points.each do |p|
      to_del<<p if p.delete_request
    end
    to_del.each do |p|
      @points.delete(p)
    end
    @delete_request = true if !active? && @points.length<=1
    to_del.length>0
  end

end