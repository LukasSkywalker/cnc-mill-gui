require 'gosu'
require_relative 'path'
require_relative 'point'

class Tutorial < Gosu::Window
  def initialize
    super 1024, 768
    self.caption = "Hack GUI"
    @drawing = false
    @paths = []
    @first_frame = true
  end
  
  def update
    if @drawing
      @paths.last.points << Point.new(self.mouse_x, self.mouse_y)
    end
  end

  def needs_redraw?
    @drawing || @first_frame
  end
  
  def draw
    @first_frame = false
    Gosu.draw_rect(10, 10, 100, 100, Gosu::Color::GREEN)

    @paths.each do |path|
      path.draw
    end
  end

  def button_down(id)
    case id
    when Gosu::MsLeft
      #run_mouse_handler(id, :down)
      @drawing = true
      @paths << Path.new
    when Gosu::KbEscape
      self.close
    end
  end

  def button_up(id)
    case id
    when Gosu::MsLeft
      #run_mouse_handler(id, :up)
      @drawing = false
    end
  end

  def run_mouse_handler(id, direction)
    object = get_overlay_object(self.mouse_x, self.mouse_y)
    if object
      object.onclick.call(self, id, direction)
    end
  end

  def needs_cursor?
    true
  end
end

Tutorial.new.show
