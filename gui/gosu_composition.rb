require_relative 'gosu_component'
class GosuComposition < GosuComponent
  def initialize(name, center=Point.new(0,0), scale_point=Point.new(0,0))
    super(name)
    @edit_mode = true
    @center = center
    @center.color = Gosu::Color::BLUE
    @center.can_connect = false
    @scale_point = scale_point
    @scale_point.color = Gosu::Color::RED
    @scale_point.name = 'Scale'
    @scale_point.can_connect = false
    @last_center = Point.new(*center.to_a)
    @last_scale_point = Point.new(*scale_point.to_a)
    @active_controlpoint = nil
    @shift_mode = false
    @last_click_propagation = nil
    @update_flags = nil
  end

  def click_action(id,pos)
    # return unless id == GosuComponent::LEFT
    if active?
      @active_controlpoint = get_active_points().find{|p| p.overlay?(*pos)}
    else
      @shift_mode = true
      @active_controlpoint = get_instance_points().find{|p| p.overlay?(*pos)}
    end
    @last_click_propagation = @active_controlpoint.onclick(id,DOWN,pos) if @active_controlpoint
  end

  def doubleclick_action(id,pos)
    return unless id == GosuComponent::LEFT
    if active?
      finish()
    else
      activate()
      @active_controlpoint = get_active_points().find{|p| p.overlay?(*pos)}
      @last_click_propagation=@active_controlpoint.onclick(id,DOWN2,pos) if @active_controlpoint
      puts "Canvas propagated doubleclick to: #{@active_controlpoint.name}"
    end
  end

  def button_up_action(id,pos)
    puts "#{self.class}: click off: #{id} --> #{@last_click_propagation.name if @last_click_propagation}"
    if !active?
      @shift_mode = id==GosuComponent::RIGHT
    end
    @last_click_propagation.onclick(id,UP,pos) if @last_click_propagation
    update_shift()
  end

  def get_instance_points
    [@scale_point,@center].reject(&:nil?).sort().reverse()
  end

  def get_dynamic_points
    @points.sort().reverse()
  end

  def get_active_points
    get_instance_points().concat(get_dynamic_points()).sort().reverse()
  end

  def update_shift
    last_updated = get_active_points().find{|p| (@last_modified.nil? ? 1 : p <=> @last_modified) > -1}
    @update_flags = nil
    if last_updated == @center
      @update_flags = :shift
      shift = (@center - @last_center)
      return false if shift.norm == 0
      shift = shift.to_a
      get_active_points().each do |p| 
        p.shift(*shift) unless p.object_id==@center.object_id
      end
      @last_scale_point.set_pos(*@scale_point.to_a) if @scale_point
    else
      @last_modified = last_updated
      new_pos = get_balance_point()
      @center.set_pos(*new_pos.to_a) unless new_pos.nil?
      if @center && @scale_point && !@scale_point.active?
        @scale_point.scale_from!(@center,farest_point_from(@center)/2.0)
        @last_scale_point.set_pos(*@scale_point.to_a)
        @scale_point.draw = true
      end
    end
    @last_center.set_pos(*@center.to_a) if @center
    true
  end

  def update_rot_scale
    return unless @scale_point
    return if @update_flags == :shift
    return if  @last_scale_point.nan? || @last_scale_point==@scale_point
    df_rot = (@last_scale_point-@center).angle_between(@scale_point-@center)
    df_rot = df_rot > 0 ? -df_rot % (2*Math::PI) : df_rot
    df_scale = (@scale_point-@center).norm.abs / (@last_scale_point-@center).norm.abs
    rot_points = get_active_points().reject{|p| [@scale_point.object_id,@center.object_id].include?(p.object_id)}
    rot_points.each do |p|
      dist = p.distance_to(@center)
      p.scale_from!(@center,df_scale*dist)
      p.rot!(@center,df_rot)
    end
    @last_scale_point.set_pos(*@scale_point.to_a)
  end

  def farest_point_from(point)
    get_active_points().reduce(0) do |m,p|
      d = p.distance_to(point);
      m < d ? d : m
    end
  end
  
  def get_balance_point
    points = get_dynamic_points()
    return nil unless points.length>0
    points.reduce(Point.new(0,0)){|memo,obj| memo += obj}/points.length.to_f
  end

  def update_deleted
    throw 'update_deleted not implemented!'
  end

  def overlay?(x,y)
    if active?
      get_active_points().any?{|p| p.overlay?(x,y)}
    else
      get_instance_points().any?{|p| p.overlay?(x,y)}
    end
  end

  def active?
    @edit_mode
  end

  def finish
    @edit_mode = false
    get_dynamic_points().each{|p| p.draw = false}
    @scale_point.draw = false
    @center.draw = false if @center
    @last_click_propagation = nil
  end

  def activate
    @edit_mode = true
    get_active_points().each{|p| p.draw = true}
    @scale_point.draw = false
    @center.draw = true
  end

  def nearest_point_in_range(point, radius)
    snappable_points = get_active_points().reject{|p| !p.can_connect}
    points = snappable_points.find_all{ |p| p.distance_to(point) <= radius }
    points = points.sort{|p,q| p.distance_to(point) <=> q.distance_to(point)}
    points.first
  end

  def has_snap_point?
    get_active_points().reject{|p| !p.draw?}.any?{|p| p.snap_mode?}
  end

  def get_snap_point
    get_active_points().reject{|p| !p.draw?}.find{|p| p.snap_mode?}
  end



end