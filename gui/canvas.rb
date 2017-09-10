require_relative 'gosu_composition'
require_relative 'gosu_line'
require_relative 'gosu_polygon'
require_relative 'gosu_arc'
require_relative 'picture'
require 'byebug'

class Canvas < GosuComposition
  attr_accessor :picture_visibility
  def initialize(gosu_window,left=0,top=0,right=0,bottom=0)
    super('Canvas')
    @left,@bottom,@right,@top = left,bottom,right,top
    @current_tool_class = nil
    @current_tool = nil
    @window = gosu_window
    @components = []
    @picture_visibility = true
    @pictures = []
  end

  def add_picture(picture)
    raise 'not a pictrue' unless picture.is_a?(Picture)
    picture.set_shift(@left,@top)
    @pictures << picture
  end

  def set_tool_class(new_tool_class)
    @current_tool_class = new_tool_class
    finish_current()
  end

  def finish_current
    @current_tool.finish() if @current_tool
    @current_tool = nil
  end

  def active?
    true
  end

  def compositions
    @picture_visibility ? @components.concat(@pictures) : @components
  end

  def onclick(id,state,pos)
    return unless overlay?(*pos)
    return unless @current_tool_class
    add_new_tool = @current_tool.nil? || !@current_tool.active?
    add_new_tool &&= id==GosuComponent::LEFT&&state==DOWN
    if t = compositions.sort().reverse().find{|c| c.overlay?(*pos)}
      @current_tool = t
      add_new_tool = false
    end
    if add_new_tool && @current_tool_class!=NilClass
      puts "canvas: new component: #{@current_tool_class}"
      @current_tool = @current_tool_class.new(Point.new(*pos), Point.new(*pos))
      @components << @current_tool
    end
    @last_click_propagation = @current_tool.onclick(id,state,pos) unless @current_tool.nil?
    self
  end
  
  def update(x,y)
    update_deleted()
    @components.each{|c| c.update(x,y)}
    @pictures.each{|c| c.update(x,y)} if @picture_visibility
    handle_point_snapping(x,y)
  end
  
  def handle_point_snapping(x,y)
    pos = Point.new(x,y)
    snap = @components.find{|c| c.has_snap_point?}
    return unless snap
    snap = snap.get_snap_point()
    snap_candidate = get_possible_snaps(pos).reject{|cand| cand.object_id == snap.object_id }.first
    return unless snap_candidate
    snap.set_snap_candidate(snap_candidate)
  end

  def get_possible_snaps(pos)
    pt = Point.new(*pos)    
    snaps = @components.reduce([]){|mem,val| mem << val.nearest_point_in_range(pt,pt.size)}.reject{|p| p.nil? || !p.draw?}
    snaps.sort{|p,q| p.distance_to(pt) <=> p.distance_to(pt)}
  end

  def update_deleted
    to_del=[]
    @components.each do |c|
      to_del<<c if c.delete_request
    end
    to_del.each do |p|
      @components.delete(p)
    end
    to_del.length>0
  end

  def overlay?(x,y)
    (x>@left&&x<@right) && (y<@bottom&&y>@top)
  end
end