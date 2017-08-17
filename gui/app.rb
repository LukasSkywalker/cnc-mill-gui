require 'gosu'

class Tutorial < Gosu::Window
  def initialize
    super 1024, 768
    self.caption = "Hack GUI"
  end
  
  def update
    # ...
  end
  
  def draw
    Gosu.draw_rect(10, 10, 100, 100, Gosu::Color::GREEN)
  end

  def button_down(id)
    puts "X: #{self.mouse_x}; Y: #{self.mouse_y}"
    case id
    when Gosu::MsLeft
      puts "left"
    when Gosu::MsRight
      puts "right"
    end
  end

  def button_up(id)
    puts "X: #{self.mouse_x}; Y: #{self.mouse_y}"
    case id
    when Gosu::MsLeft
      puts "left"
    when Gosu::MsRight
      puts "right"
    end
  end
end

Tutorial.new.show
