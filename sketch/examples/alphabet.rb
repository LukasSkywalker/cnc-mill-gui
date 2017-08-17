require_relative '../sketch'
require_all(__FILE__)

s = Sketch.new(Laser.new)
s << Positioning.new(-95, 0)

('a'..'c').each do |letter|
  s << Letter.new(letter, letter_size: 10)
end

s << Positioning.new(0, 0)

s.run
