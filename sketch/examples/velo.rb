require_relative '../sketch'
require_all(__FILE__)

s = Sketch.new(Laser.new(power: 1000))

s << FeedRate.new(400)
s << Positioning.new(10, 0, Command::RELATIVE)
s << Arc.new([0, 10], 360, Arc::CLOCKWISE, Command::RELATIVE)
s << Positioning.new(40, 0, Command::RELATIVE)
s << Arc.new([0, 10], 360, Arc::CLOCKWISE, Command::RELATIVE)

s << Positioning.new(0, 30, Command::RELATIVE)
s << LineTo.new(-40, -20, Command::RELATIVE)
s << LineTo.new(10, 20, Command::RELATIVE)
s << LineTo.new(30, 0, Command::RELATIVE)
s << LineTo.new(0, -20, Command::RELATIVE)

s << Positioning.new(0, 20, Command::RELATIVE)
s << LineTo.new(0, 5, Command::RELATIVE)
s << LineTo.new(-10, 0, Command::RELATIVE)
s << LineTo.new(20, 0, Command::RELATIVE)

s.simulate
