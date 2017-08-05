require_relative 'sketch'
require_all(__FILE__)

s = Sketch.new(Laser.new)
s << Positioning.new(10, 10)
s << LineTo.new(20, 20)
s << LineTo.new(30, 30)
s << Pause.new(10)
s << Positioning.new(0, 0)
s << Arc.new([20,0],180, Arc::CLOCKWISE)
# s << Positioning.new(0, 0)
s << Arc.new([20,0],180, Arc::COUNTER_CLOCKWISE)
# s << Arc.new(1,2,3,4,5)
puts s.debug
