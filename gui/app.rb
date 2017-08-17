require 'gosu'
require_relative 'path'
require_relative 'point'
require_relative 'button'
require_relative 'toggle_button'

require_relative 'event_handler'
require_relative 'object_manager'

class Tutorial < Gosu::Window
  include EventHandler

  WIDTH = 1024
  HEIGHT = 768

  def initialize
    super WIDTH , HEIGHT
    self.caption = "Hack GUI"
    @first_frame = true
    @object_manager = ObjectManager.new
    @object_manager.add(Point.new(100,100),0)
    @object_manager.add(Point.new(200,100),0)
    @object_manager.add_button(Button.new(self,"Point",0,20,Proc.new {
      @object_manager.add(Point.new(self.mouse_x,self.mouse_y),0)
    }))
    @object_manager.add_button(Button.new(self,"Line",100,20))
    @object_manager.add_button(Button.new(self,"Free",200,20))
    @object_manager.add_button(Button.new(self,"Polygon",300,20))
    @object_manager.add_button(ToggleButton.new(self,"Select",400,20))
  end
  
  def update
  end

  def draw
    @object_manager.update(self.mouse_x,self.mouse_y)
  end

  def needs_cursor?
    true
  end
end

Tutorial.new.show
