require_relative 'gosu_composition'
require_relative 'gosu_line'
require_relative 'gosu_polygon'
require_relative 'gosu_arc'
require 'byebug'

# require_relative 'app'

class Canvas < GosuComposition
  def initialize(gosu_window,left=0,bottom=0,right=0,top=0)
    super('Canvas')
    @left,@bottom,@right,@top = left,bottom,right,top
    @current_tool_class = nil
    @current_tool = nil
    # 0,0,App::WIDTH,App::HEIGHT
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

  # def update_tool(id,state)
  #   tool = @object_manager.get_active_button(:tools)
  #   return unless tool
  #   if tool.text.downcase.to_sym != @state[:action]
  #     case @state[:action]
  #     when :line
  #       return if @state[:current_line]
  #       @state[:current_line] = nil
  #     when :polygon
  #       return if @state[:current_line]
  #       @state[:current_polygon] = nil
  #     end
  #   end
  #   @state[:action] = tool.text.downcase.to_sym
  # end

  def active?
    true
  end

  def onclick(id,state,pos)
    return unless overlay?(*pos)
    return unless @current_tool_class
    add_new_tool = @current_tool.nil? || !@current_tool.active?
    if t = @components.sort().reverse().find{|c| c.overlay?(*pos)}
      @current_tool = t
      add_new_tool = false
    end
    if add_new_tool
      puts "canvas: new component: #{@current_tool_class}"
      @current_tool = @current_tool_class.new(Point.new(*pos), Point.new(*pos))
      @components << @current_tool
    end
    @last_click_propagation =@current_tool.onclick(id,state,pos)
    puts "canvas propagated click to #{@current_tool.name}"
    self
  end

  def point_action(id,state)
    return handle_key(id,state) unless @state.has_key?(id)
    return unless id==GosuComponent::LEFT
    case state
    when DOWN
      pos = [@window.mouse_x,@window.mouse_y]
      @object_manager.add(Point.new(*pos),0)
    end
  end

  def get_current_object
    case @state[:action]
    when :line
      return @state[:current_line] if @state[:current_line]&&@state[:current_line].active?
    when :arc
      return @state[:current_arc] if @state[:current_arc]&&@state[:current_arc].active?
    when :polygon
      return @state[:current_polygon] if @state[:current_polygon]&&@state[:current_polygon].active?
    end
    nil
  end
  
  def arc_action(id,state)
    return handle_key(id,state) unless @state.has_key?(id)
    return unless id==GosuComponent::LEFT
    init = false
    if !@state[:current_arc]
      @state[:current_arc] = GosuArc.new
      @object_manager.add(@state[:current_arc],0)
      init = true
    end
    case state
    when DOWN
      point = Point.new(@window.mouse_x,@window.mouse_y)
      @object_manager.add(point,0)
      if init
        radius_control = Point.new(@window.mouse_x,@window.mouse_y)
        @object_manager.add(radius_control,-1)
        ende = Point.new(@window.mouse_x,@window.mouse_y)
        @object_manager.add(ende,1)
        @state[:current_arc].set(start: point, ende: ende, radius_control: radius_control)
      else
        @state[:current_arc].set(center: point)
        @state[:current_arc]=nil
      end
    end
  end

  def update(x,y)
    @components.each{|c| c.update(x,y)}
  end

  def delete?
    false
  end

  def overlay?(x,y)
    (x>@left&&x<@right) && (y>@bottom&&y<@top)
  end
end