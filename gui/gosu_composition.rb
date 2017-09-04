require_relative 'gosu_component'
class GosuComposition < GosuComponent
  def initialize(name, center=Point.new(0,0), scale_point=Point.new(0,0))
    super(name)
    @edit_mode = true
    @center = center
    @center.color = Gosu::Color::BLUE
    @scale_point = scale_point
    @scale_point.color = Gosu::Color::GREEN
    @scale_point.draw = false
    @last_center = Point.new(*center.to_a)
    @active_controlpoint = nil
    @shift_mode = false
    @last_click_propagation = nil
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
    last_updated = get_active_points().find{|p| (p <=> @last_modified) > -1}
    if last_updated == @center
      shift = (@center - @last_center)
      return false if shift.norm == 0
      shift = shift.to_a
      get_active_points().each do |p| 
        p.shift(*shift) unless p.object_id==@center.object_id
      end
    else
      @last_modified = last_updated
      new_pos = get_balance_point()
      @center.set_pos(*new_pos.to_a) unless new_pos.nil?
    end
    @last_center.set_pos(*@center.to_a) if @center
    true
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
    points = get_active_points().find_all{ |p| p.distance_to(point) <= radius }
    points.sort{|p,q| p.distance_to(point) <=> q.distance_to(point)}
    points.first
  end

  def has_snap_point?
    get_active_points().reject{|p| !p.draw?}.any?{|p| p.snap_mode?}
  end


  def get_snap_point
    get_active_points().reject{|p| !p.draw?}.find{|p| p.snap_mode?}
  end

  def handle_point_snapping(snap_candidate, snap)
    return unless snap_candidate
    return unless snap
    # if click_off
      # @last_click_propagation.connect_point(snap_candidate)
    # else
      snap.set_pos(*snap_candidate.to_a)
    # end
  end

end