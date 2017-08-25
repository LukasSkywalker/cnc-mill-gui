require_relative 'gosu_component'
class GosuComposition < GosuComponent
  def initialize(name, center=Point.new(0,0), scale_point=Point.new(0,0))
    super(name)
    @edit_mode = true
    @center = center
    @scale_point = scale_point
    @last_center = Point.new(*center.to_a)
    @active_controlpoint = nil
    @shift_mode = false
    @last_click_propagation = nil
  end

  def recreate(pos)
    self.class.new(self.name,Point.new(*pos))
  end

  def click_action(id,pos)
    puts "gosu_composition: click #{id}" 
    return unless id == GosuComponent::LEFT
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
    puts 'LineDubleClick'
    if active?
      finish()
    else
      activate()
      @active_controlpoint = get_active_points().find{|p| p.overlay?(*pos)}
      @active_controlpoint.onclick(id,DOWN2,pos) if @active_controlpoint
    end
  end

  def button_up_action(id,pos)
    puts 'click off'
    return unless id == GosuComponent::LEFT
    if active?
      @last_click_propagation.onclick(id,UP,pos) if @last_click_propagation
    else
      @shift_mode = false
      @last_click_propagation.onclick(id,UP,pos) if @last_click_propagation
    end
  end

  def get_instance_points
    [@scale_point,@center].reject(&:nil?)
  end

  def get_active_points
    get_instance_points().concat(@points)
  end

  def update_shift
    last_updated = get_active_points().find{|p| p > @last_modified}
    if last_updated
      @last_modified = last_updated
      new_pos = get_balance_point()
      @center.set_pos(*new_pos.to_a)
    else
      shift = (@center - @last_center).to_a
      get_active_points().each do |p|
        p.shift(*shift)
      end
    end
    @last_center.set_pos(*@center.to_a)
  end

  def get_balance_point
    points = get_active_points()
    points.reduce(Point.new(0,0)){|memo,obj| memo += obj}/points.length.to_f
  end

  def update_deleted
    throw 'update_deleted not implemented!'
  end

  def overlay?(x,y)
    if active?
      get_active_points().any?{|p| p.overlay?(x,y)}
    else
      get_instance_points().any?{|p| p.overlay?(x,y)} || @end.overlay?(x,y)
    end
  end

  def get_overlay_object(x, y)
    if active?
      get_active_points().find{|p| p.overlay?(x,y)}
    else
      get_instance_points().find{|p| p.overlay?(x,y)} || @end.overlay?(x,y)
    end
    nil
  end

  def active?
    @edit_mode
  end

  def finish
    @edit_mode = false
    get_active_points().each{|p| p.draw = false}
    @center.draw = false
  end

  def activate
    @edit_mode = true
    get_active_points().each{|p| p.draw = true}
    @center.draw = true
  end


end