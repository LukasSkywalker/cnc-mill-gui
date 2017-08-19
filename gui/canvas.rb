require_relative 'gosu_object'
require_relative 'line'
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
    @state[:action]=:arc
    @elements = {}
  end

  def active?
    true
  end

  def onclick(id,state)
    @actions[@state[:action]].call(id,state)
  end

  def point_action(id,state)
    return handle_key(id,state) unless @state.has_key?(id)
    return unless id==GosuObject::LEFT
    case state
    when DOWN
      pos = [@window.mouse_x,@window.mouse_y]
      @object_manager.add(Point.new(*pos),0)
      @elements[Time.now] = pos
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
    
  end
  
  def arc_action(id,state)
    return handle_key(id,state) unless @state.has_key?(id)
    return unless id==GosuObject::LEFT
    if !@state[:current_arc]
      @state[:current_arc] = GosuArc.new
      @object_manager.add(@state[:current_arc],0)
    end
    case state
    when DOWN
      point = Point.new(@window.mouse_x,@window.mouse_y)
      @object_manager.add(point,0)
      if !@state[:current_arc].complete?
        point2 = Point.new(@window.mouse_x,@window.mouse_y)
        @object_manager.add(point2,0)
        @state[:current_arc].add(point,point2)
      else
        @state[:current_arc].add(point)
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