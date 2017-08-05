require_relative 'status'

class Tool
  VERTICAL_OFFSET = 3
  attr_reader :status
  
  def initialize
    @status = Status.new(on: false)
  end

  def on

  end

  def off
  
  end
end