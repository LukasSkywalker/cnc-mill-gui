require 'gosu'
require_relative 'path'
require_relative 'point'

require_relative 'event_handler'
require_relative 'object_manager'

class Tutorial < Gosu::Window
  include EventHandler

  def initialize
    super 1024, 768
    self.caption = "Hack GUI"
    @drawing = false
    @paths = []
    @first_frame = true
    @object_manager = ObjectManager.new
    @object_manager.add(Point.new(100,100),0)
    @object_manager.add(Point.new(200,100),0)
  end
  
  def update
    # if @drawing
    #   @paths.last.points << Point.new(self.mouse_x, self.mouse_y)
    # end
  end

  def needs_redraw?
    true#@drawing || @first_frame
  end
  
  def draw
    @object_manager.update(self.mouse_x,self.mouse_y)
    # @first_frame = false
    # Gosu.draw_rect(10, 10, 100, 100, Gosu::Color::GREEN)

    # @paths.each do |path|
    #   path.draw
    # end
  end

  def needs_cursor?
    true
  end
end

Tutorial.new.show
