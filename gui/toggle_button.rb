require_relative 'button'

class ToggleButton < Button
  def initialize(window,text, x, y, action=->{})
    super
  end

  def active?
    @on
  end

  def activate
    @on = true
  end

  def deactivate
    @on = false
  end

  def update(x,y)
    clicked = (!@state[LEFT] && @state[CHANGED]==LEFT)
    if clicked
      @on = !@on
      @selfautocracy_request = true if @on
    end
    @state[CHANGED] = nil if @state[CHANGED]
    draw
  end
end