require_relative 'gosu_composition'
require_relative 'gosu_line'
require_relative 'gosu_polygon'
require_relative 'gosu_arc'
require 'byebug'

class Canvas < GosuComposition
  def initialize(gosu_window,left=0,bottom=0,right=0,top=0)
    super('Canvas')
    @left,@bottom,@right,@top = left,bottom,right,top
    @current_tool_class = nil
    @current_tool = nil
    @window = gosu_window
    @components = []
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

  def onclick(id,state,pos)
    return unless overlay?(*pos)
    return unless @current_tool_class
    add_new_tool = @current_tool.nil? || !@current_tool.active?
    add_new_tool &&= id==GosuComponent::LEFT&&state==DOWN
    if t = @components.sort().reverse().find{|c| c.overlay?(*pos)}
      @current_tool = t
      add_new_tool = false
    end
    if add_new_tool
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
    (x>@left&&x<@right) && (y>@bottom&&y<@top)
  end
end