require_relative 'gosu_composition'
require_relative 'point'
require 'byebug'

class GosuLine < GosuComposition
  def initialize(center_point)
    super('Line',center_point, Point.new(0,0))
    @points = []
    @last_modified = Time.new(0)
  end

  def click_action(id,pos)
    puts "lineClick #{id}"
    return unless id == GosuComponent::LEFT
    if active?
      if get_active_points().any?{|p| p.overlay?(*pos)}
        @active_controlpoint = get_active_points().find{|p| p.overlay?(*pos)}
      else
        @active_controlpoint = Point.new(*pos)
        @points<<@active_controlpoint
      end    
    else
      @shift_mode = true
      @active_controlpoint = get_instance_points().find{|p| p.overlay?(*pos)}
    end
    @last_click_propagation = @active_controlpoint.onclick(id,DOWN,pos) if @active_controlpoint
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
    draw(x,y)
  end

  def draw(x,y)
    if @points.length > 0
      # byebug
      ppair = active?() ? @points.zip([*@points[0..-1],Point.new(x,y)]) : @points[0..-2].zip(@points[1..-1])
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