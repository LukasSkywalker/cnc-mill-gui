require_relative 'gosu_component'

class Button < GosuComponent
  attr_reader :text
  attr_accessor :selfautocracy_request, :x, :y

  SIZE = [95,30]
  TIME_INTERVALL = 20

  def initialize(window,text, x, y, action=->{})
    super("Button_#{text.gsub(' ','')}",*get_border(x,y))
    @action = action
    @x = x
    @y = y
    @text = text
    @on = false
    @timer = 0
    @font = Gosu::Font.new(window, Gosu::default_font_name, 24)
    @selfautocracy_request = false
  end

  def button_up_action(id,pos)
  end

  def get_border(x=@x,y=@y)
    [x,y,x+SIZE.first,y+SIZE.last]
  end

  def click_action(id,pos)
    return unless id==LEFT
    puts "button #{@name}: click on"
    active? ? deactivate() : activate()
    @action.call(self)
  end
  
  def active?
    @on
  end
  
  def activate
    @on = true
    @selfautocracy_request = true if @on
  end
  
  def deactivate
    @on = false
  end
  
  def update(x,y)
    draw()
  end
  
  def draw
    Gosu.draw_rect(@x,@y, SIZE.first,SIZE.last, active? ? Gosu::Color::GREEN : Gosu::Color::RED,-999)
    @font.draw(@text, @x+5,@y+5,1, 1.0, 1.0, Gosu::Color::WHITE)
  end
end