require_relative '../sketch'
require_all(__FILE__)

s = Sketch.new(Laser.new(power: 1000))

s << FeedRate.new(1000)
s << Positioning.new(20, 20, Command::RELATIVE)

#s.simulate
s.run
