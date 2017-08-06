require_relative 'status'

class Tool
  VERTICAL_OFFSET = 3
  attr_reader :status, :is_relative
  
  def initialize
    @status = Status.new(on: false, position: [0.0,0.0], bounding_box: [0,0,0,0])
    @is_relative = false
  end

  def reset
    update_position(0.0,0.0)
  end

  def update_position(x,y)
    update_bounding_box(x,y)
    @status.position = [x,y]
  end

  def update_bounding_box(x,y)
    @status.bounding_box[0] = x if @status.bounding_box[0] > x
    @status.bounding_box[1] = y if @status.bounding_box[1] > y
    @status.bounding_box[2] = x if @status.bounding_box[2] < x
    @status.bounding_box[3] = y if @status.bounding_box[3] < y
  end

  def on

  end

  def off
  
  end
end