require 'gosu'
require_relative 'point'
require_relative 'button'
require_relative 'picture'

require_relative 'event_handler'
require_relative 'canvas'
require_relative 'controls'
require_relative 'gosu_freehand'

class App < Gosu::Window
  include EventHandler

  WIDTH = 1024
  HEIGHT = 768

  def initialize
    super App::WIDTH , App::HEIGHT
    self.caption = "Hack GUI"
    @first_frame = true
    @canvas = Canvas.new(self,0,40,WIDTH,HEIGHT)
    @canvas.add_picture(Picture.new('/home/bauz/Pictures/flyer01.jpg').set_pos(Point.new(0,0),Point.new(250,Float::NAN)))
    @canvas.add_picture(Picture.new('/home/bauz/Pictures/bellvue.jpg').set_pos(Point.new(500,300),Point.new(800,Float::NAN)))
    @controls = Controls.new('Control Bar', 0,0,WIDTH,40)
    @controls.add_button(Button.new(self,"Select",410,5,button_proc(NilClass)).activate())
    @controls.add_button(Button.new(self,"Line",10,5,button_proc(GosuLine)))
    @controls.add_button(Button.new(self,"Arc",110,5,button_proc(GosuArc)))
    @controls.add_button(Button.new(self,"Polygon",210,5,button_proc(GosuPolygon)))
    @controls.add_button(Button.new(self,"Freehand",310,5,button_proc(GosuFreehand)))
    @controls.add_button(Button.new(self,"Show Pics",WIDTH-100,5,Proc.new{
        |object| @canvas.picture_visibility = object.active?
      }).activate(),:picture)
    @canvas.set_tool_class(NilClass)
  end

  def button_proc(tool_class)
    Proc.new{ |object|
      if object.active?
        @canvas.finish_current()
        @canvas.set_tool_class(tool_class)
      else
        @canvas.finish_current()
      end
    }
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