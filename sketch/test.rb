require_relative 'sketch'
require_all(__FILE__)

s = Sketch.new(Laser.new)
s << Positioning.new(10, 10)
s << LineTo.new(20, 30)
s << LineTo.new(50, 30)
s << LineTo.new(100,0, Command::RELATIVE)
s << LineTo.new(0,-100, Command::RELATIVE)
s << LineTo.new(30,200, Command::RELATIVE)

s << Pause.new(10)
s << Positioning.new(0, 0)
(-20..20).step(20).each do |x|
  (-20..20).step(20).each do |y|
    next if x==0 && y==0
    s << Positioning.new(0, 0)
    s << Arc.new([x,y],230, Arc::CLOCKWISE)
  end
end

s << Positioning.new(60, 0)
s << Arc.new([20,0],180, Arc::CLOCKWISE, Command::RELATIVE)
s << Arc.new([20,0],180, Arc::COUNTER_CLOCKWISE, Command::RELATIVE)
s << Positioning.new(-10,10, Command::RELATIVE)
s << Arc.new([120,0],90, Arc::COUNTER_CLOCKWISE)
s << Positioning.new(90, -10)
s << Arc.new([-10,10],90, Arc::CLOCKWISE, Command::RELATIVE)
s << Positioning.new(-60, 0)
s << Polygon.new([-60,0],[-60,-50],[-30,-80],[-10,0],[-20,40],[-40,100],[-30,120],[0,0])
(-100..0).step(10).each do |y|
  s << Positioning.new(0,y)
  s << Polygon.new([-90,-300],[-50,-50],[-180,50],[-200,0], Command::RELATIVE)
end

s.simulate
