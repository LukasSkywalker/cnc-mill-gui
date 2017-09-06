require_relative '../sketch'
require_all(__FILE__)

s = Sketch.new(Laser.new(power: 1000))

s << FeedRate.new(100)

for i in 1..20
  s << LineTo.new(0, 10, Command::RELATIVE)
  s << LineTo.new(10, 0, Command::RELATIVE)
  s << LineTo.new(0, -10, Command::RELATIVE)
  s << LineTo.new(-10, 0, Command::RELATIVE)
  s << Up.new(i / 2.0, Command::ABSOLUTE)
end

s.run
