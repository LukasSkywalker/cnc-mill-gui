require_relative 'sketch'

require_relative 'laser'

require_relative 'positioning'
require_relative 'line_to'

s = Sketch.new(Laser.new)
s << Positioning.new(10, 10)
s << LineTo.new(20, 20)
s << LineTo.new(30, 30)
s << Positioning.new(0, 0)
#s << Arc.new(1,2,3,4,5)
puts s.debug
