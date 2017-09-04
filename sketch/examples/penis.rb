require_relative '../sketch'
require_all(__FILE__)

s = Sketch.new(Laser.new(power: 1000))

s << FeedRate.new(50)

sleep(5)

s << Arc.new([10, 0], 360, Arc::CLOCKWISE, Command::RELATIVE)
s << Positioning.new(30, 0, Command::RELATIVE)
s << Arc.new([10, 0], 360, Arc::CLOCKWISE, Command::RELATIVE)

s << Positioning.new(15, 9, Command::ABSOLUTE)
s << LineTo.new(0, 50, Command::RELATIVE)
s << Arc.new([10, 0], 180, Arc::CLOCKWISE, Command::RELATIVE)
s << LineTo.new(0, -50, Command::RELATIVE)

s << Positioning.new(15, 55, Command::ABSOLUTE)
s << LineTo.new(20, 0, Command::RELATIVE)
s << Positioning.new(-10, 0, Command::RELATIVE)
s << LineTo.new(0, 14, Command::RELATIVE)

s << Positioning.new(0, 0, Command::ABSOLUTE)

s.run
