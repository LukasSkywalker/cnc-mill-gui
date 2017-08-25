require 'gosu'
require_relative 'path'
require_relative 'point'
require_relative 'button'

require_relative 'event_handler'
# require_relative 'object_manager'
require_relative 'canvas'
require_relative 'controls'

class App < Gosu::Window
  include EventHandler

  WIDTH = 1024
  HEIGHT = 768

  def initialize
    super App::WIDTH , App::HEIGHT
    self.caption = "Hack GUI"
    @first_frame = true
    @canvas = Canvas.new(self)
    @controls = Controls.new('Control Bar', 0,40,WIDTH,0)
    @controls.add_button(Button.new(self,"Line",10,5,Proc.new{ |object|
      if object.active?
        @canvas.current_composition = GosuLine.new(Point.new(0,0))
      else
        @canvas.current_composition.finish() unless @canvas.current_composition.nil?
      end
    }))
    @controls.add_button(Button.new(self,"Arc",110,5))
    @controls.add_button(Button.new(self,"Polygon",210,5))
    @controls.add_button(Button.new(self,"Freehand",310,5))

    # @object_manager = ObjectManager.new
    # @object_manager.add(Point.new(100,100),0)
    # @object_manager.add(Point.new(200,100),0)
    # @object_manager.add_button(ToggleButton.new(self,"Point",0,20,Proc.new {
    #   @object_manager.add(Point.new(self.mouse_x,self.mouse_y),0)
    # }), :tools)
    # @object_manager.add_button(ToggleButton.new(self,"Line",100,20), :tools)
    # @object_manager.add_button(ToggleButton.new(self,"Arc",200,20), :tools)
    # @object_manager.add_button(ToggleButton.new(self,"Polygon",300,20), :tools)
    # @object_manager.add_button(ToggleButton.new(self,"Freehand",400,20), :tools)
    # @object_manager.add_button(ToggleButton.new(self,"Select",500,20))
    # @object_manager.add(Canvas.new(self,@object_manager),-999)
  end
  
  def update
  end

  def draw
    @controls.update(self.mouse_x,self.mouse_y)
    @canvas.update(self.mouse_x,self.mouse_y)
    # @object_manager.update(self.mouse_x,self.mouse_y)
  end

  def needs_cursor?
    true
  end
end

App.new.show
