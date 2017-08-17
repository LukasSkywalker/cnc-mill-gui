require_relative 'button'

class ToggleButton < Button
  def initialize(window,text, x, y)
    super
  end

  def active?
    @on
  end

  def update(x,y)
    @on = !@on if (!@state[LEFT] && @state[CHANGED]==LEFT)
    @state[CHANGED] = nil if @state[CHANGED]
    draw
  end
end