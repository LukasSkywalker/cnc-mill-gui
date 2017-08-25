require_relative 'gosu_composition'
require_relative 'gosu_line'
require_relative 'gosu_polygon'
require_relative 'gosu_arc'

# require_relative 'app'

class Canvas < GosuComposition
  attr_accessor :current_composition
  def initialize(gosu_window)
    super('Canvas')
    @current_composition = nil
    # 0,0,App::WIDTH,App::HEIGHT
    @window = gosu_window
    @components = []
    # @actions = {:line=>self.method(:line_action),
    #   :polygon=>self.method(:polygon_action),
    #   :arc=>self.method(:arc_action),
    #   :point=>self.method(:point_action),
    #   :freehand=>self.method(:freehand_action)}
    # @state[:action]=:line
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
    puts 'canvas: click on'
    if @current_composition
      @current_composition = @current_composition.recreate(pos) unless @current_composition.active?
      @components << @current_composition unless @components.include?(@current_composition)
      @current_composition.onclick(id,state,pos)
      puts "canvas propagated click to #{@current_composition.name}"
    end
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

  def line_action(id,state)
    return handle_key(id,state) unless @state.has_key?(id)
    return unless id==GosuComponent::LEFT
    if !@state[:current_line] || !@state[:current_line].active?
      point = Point.new(@window.mouse_x,@window.mouse_y,Gosu::Color::BLUE,20.0)
      @object_manager.add(point,1)
      # point2 = Point.new(@window.mouse_x,@window.mouse_y,Gosu::Color::RED,20.0)
      # @object_manager.add(point2,1)
      @state[:current_line] = GosuLine.new(point)
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
    return unless id==GosuComponent::LEFT
    if !@state[:current_polygon] || !@state[:current_polygon].active?
      @state[:current_polygon] = nil
    end
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

  def freehand_action(id,state)
  end

  def update(x,y)
    @components.each{|c| c.update(x,y)}
  end

  def delete?
    false
  end
end