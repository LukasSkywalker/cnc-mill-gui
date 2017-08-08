require_relative '../sketch'
require_all(__FILE__)

s = Sketch.new(Laser.new(power: 1000))

s << FeedRate.new(400)
s << LineTo.new(20, 0, Command::RELATIVE)
s << Positioning.new(10, 0, Command::RELATIVE)

s << Arc.new([10, 10], 360, Arc::CLOCKWISE, Command::RELATIVE)

s << Positioning.new(0, 0)

#s.simulate
s.run
