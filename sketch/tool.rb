require_relative 'status'

class Tool
  VERTICAL_OFFSET = 3
  attr_reader :status
  
  def initialize
    @status = Status.new(on: false, position: [0.0,0.0])
  end

  def reset
    update_position(0.0,0.0)
  end

  def update_position(x,y)
    @status.position = [x,y]
  end

  def shift_position(shift_x, shift_y)
    pos = @status.position
    @status.position = [pos[0]+shift_x,pos[1]+shift_y]
  end

  def on

  end

  def off
  
  end
end