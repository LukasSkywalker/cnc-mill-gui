require_relative 'button'

class PushButton < Button
  def initialize(window,text, x, y, action=->{})
    super
  end

  def click_action(id,pos)
    return unless id==LEFT
    puts "button #{@name}: click on"
    activate
  end

  def active?
    @timer > 0
  end

  def activate
    @timer += TIME_INTERVALL+1
  end
  
  def deactivate
    @timer = 0
  end

  def update(x,y)
    @timer -= 1 if @timer > 0
    draw()
  end
end
