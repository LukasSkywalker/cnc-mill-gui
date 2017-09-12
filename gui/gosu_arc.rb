require_relative 'gosu_composition'
require_relative 'point'
require_relative '../sketch/arc'
require 'byebug'

class GosuArc < GosuComposition
  def initialize(center_point,scale_point)
    super('Arc',center_point,scale_point)
    @start=@center=@end=nil
    @edit_mode = true
  end

  def get_instance_points
    [@start,@end,@center,@scale_point].reject(&:nil?).sort().reverse()
  end

  def get_dynamic_points
    []
  end

  def click_action(id,pos)
    if active?
      if get_active_points().any?{|p| p.overlay?(*pos)} && @end
        @active_controlpoint = get_active_points().find{|p| p.overlay?(*pos)}
      elsif id == GosuComponent::LEFT
        if @start.nil?
          @start = Point.new(*pos,Gosu::Color::GREEN)
          @active_controlpoint = @end = Point.new(*pos,Gosu::Color::RED)
        elsif @center.nil?
          @active_controlpoint = @center = Point.new(*pos)
          @last_center = Point.new(*@center.to_a)
          # finish()
        end
      end
    else
      @shift_mode = id == GosuComponent::LEFT
      @active_controlpoint = get_instance_points().find{|p| p.overlay?(*pos)}
    end
    @last_click_propagation = @active_controlpoint.onclick(id,DOWN,pos) if @active_controlpoint
  end

  def active?
    @edit_mode
  end

  def update(x,y)
    return if @start.nil?
    update_deleted()
    draw(x,y)
    update_control_points()
    update_rot_scale()    
    get_active_points().each{|p| p.update(x,y)}
  end
  
  def draw(x,y)
    return if !@draw
    angle = 2*Math::PI
    last_pos = Point.new(@start.x,@start.y)
    center = @center.nil? ? Point.new(x,y) : @center
    return if @start==center
    if @start!=@end
      angle = (@start-center).angle_between(@end-center).abs
    end
    r = radius(center)
    angle_offset = (@start-center).angle_offset.abs
    (0..angle).step(Arc::PRECISION_RAD) do |d|
      d = d-angle_offset
      cos = r*Math.cos(d)
      sin = r*Math.sin(d)
      pos = (center+Point.new(cos,sin))
      Gosu.draw_line(*last_pos.to_a,Gosu::Color::GREEN,*pos.to_a, Gosu::Color::GREEN)
      last_pos = pos
    end
    Gosu.draw_line(*last_pos.to_a,Gosu::Color::RED,@end.x,@end.y, Gosu::Color::RED)
  end
  
  def update_control_points
    return 0 unless @center
    update_shift()
    r = radius(@center)
    update_radius(@center,r)
    r
  end

  def radius(center=@center)
    return 0 unless @start && center
    center.distance_to(@start > @end ? @end : @start)
  end

  def update_radius(center,r)
    @start.set_pos(*(center + (@start - center).scale!(r)).to_a)
    @end.set_pos(*(center + (@end - center).scale!(r)).to_a)    
  end
  
  def update_deleted
    [@start,@center,@end,@scale_point].each do |p|
      @delete_request = true if p && p.delete_request
    end
  end
end