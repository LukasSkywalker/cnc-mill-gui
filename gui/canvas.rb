require_relative 'gosu_object'
require_relative 'line'
require_relative 'gosu_polygon'
require_relative 'gosu_arc'

# require_relative 'app'

class Canvas < GosuObject
  def initialize(gosu_window,object_manager)
    super('Canvas',0,0,App::WIDTH,App::HEIGHT)
    @object_manager = object_manager
    @window = gosu_window
    @actions = {:line=>self.method(:line_action),
      :polygon=>self.method(:polygon_action),
      :arc=>self.method(:arc_action),
      :point=>self.method(:point_action)}
    @state[:action]=:line
  end

  def update_tool()
    tool = @object_manager.get_active_button(:tools)
    return unless tool
    if tool.text.downcase.to_sym != @state[:action]
      case @state[:action]
      when :line
        @state[:current_line].finish if @state[:current_line]
        @state[:current_line] = nil
      when :polygon
        @state[:current_polygon].finish if @state[:current_line]
        @state[:current_polygon] = nil
      end
    end
    @state[:action] = tool.text.downcase.to_sym
  end

  def active?
    true
  end

  def onclick(id,state)
    update_tool()
    @actions[@state[:action]].call(id,state)
  end

  def point_action(id,state)
    return handle_key(id,state) unless @state.has_key?(id)
    return unless id==GosuObject::LEFT
    case state
    when DOWN
      pos = [@window.mouse_x,@window.mouse_y]
      @object_manager.add(Point.new(*pos),0)
    end
  end

  def line_action(id,state)
    return handle_key(id,state) unless @state.has_key?(id)
    return unless id==GosuObject::LEFT
    if !@state[:current_line]
      @state[:current_line] = Line.new
      @object_manager.add(@state[:current_line],0)
    end
    case state
    when DOWN
      point = Point.new(@window.mouse_x,@window.mouse_y)
      @object_manager.add(point,0)
      @state[:current_line].add(point)
    end
  end

  def polygon_action(id,state)
    return handle_key(id,state) unless @state.has_key?(id)
    return unless id==GosuObject::LEFT
    if !@state[:current_polygon]
      point = Point.new(@window.mouse_x,@window.mouse_y)
      @object_manager.add(point,1)
      @state[:current_polygon] = GosuPolygon.new(point)
      @object_manager.add(@state[:current_polygon],0)
    end
    case state
    when DOWN
      point = Point.new(@window.mouse_x,@window.mouse_y)
      @object_manager.add(point,0)
      @state[:current_polygon].add(point)
    end
    
  end
  
  def arc_action(id,state)
    return handle_key(id,state) unless @state.has_key?(id)
    return unless id==GosuObject::LEFT
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
  end

  def delete?
    false
  end
end