require_relative '../sketch'
require_all(__FILE__)

SCALE = 0.5
LEFT = -1
RIGHT = 1


def scale(*data)
  data.map do |d|
    if d.is_a?(Array)
      s = scale(*d)
      puts s.inspect
      s
    else
      d*SCALE
    end
  end
end

def multiply(data,fact)
  [data]*fact
end


def wing(sketch, center_top_x=0.0,center_top_y=0.0, side=RIGHT)
  sketch << Positioning.new(center_top_x,center_top_y)
  sketch << LineTo.new(*scale(side*240,0),Command::RELATIVE)
  sketch << Polygon.new(*scale([side*30,0],[side*30,-10],[side*15,-50],[0,-60]),Command::RELATIVE)
  sketch << LineTo.new(center_top_x,center_top_y-scale(105).first)
end

def heck(sketch, center_top_x=0.0,center_top_y=0.0, side=RIGHT)
  sketch << Positioning.new(center_top_x,center_top_y)
  sketch << LineTo.new(*scale(0,-8),Command::RELATIVE)
  sketch << Positioning.new(center_top_x,center_top_y)
  sketch << LineTo.new(*scale(side*105,-24),Command::RELATIVE)
  sketch << Polygon.new(*scale([side*20,-5],[side*9,-25],[0,-38]),Command::RELATIVE)
  sketch << Polygon.new(*scale([side*-45,-10],[side*-91,-7]),Command::RELATIVE)
  sketch << Polygon.new([center_top_x+(side*scale(1).first),center_top_y-scale(63).first],[center_top_x,center_top_y-scale(51).first])
end

def body(sketch, center_top_x=0.0,center_top_y=0.0)
  sketch << Positioning.new(center_top_x,center_top_y)
  sketch << Polygon.new(*scale([80,5],[157,0]),Command::RELATIVE)
  sketch << Polygon.new(*scale(*multiply([16,18],3),*multiply([216,-20],4),[266,52]),Command::RELATIVE)
  sketch << Polygon.new(*scale([20,10],[40,0]),Command::RELATIVE)
  sketch << LineTo.new(*scale(12,-67),Command::RELATIVE)
  sketch << Polygon.new(*scale([5,-40],[-26,-40]),Command::RELATIVE)
  sketch << Polygon.new(*scale([-300,-20],*multiply([-420,0],2),[-449,27]),Command::RELATIVE)
  sketch << Polygon.new([center_top_x-scale(35).first,center_top_y-scale(10).first],[center_top_x,center_top_y])
  # slit
  (0..1).each do |yd|
    sketch << Positioning.new(center_top_x+scale(126).first,center_top_y-scale(35-yd).first)
    sketch << Polygon.new(*scale([25,13],[105,-2]),Command::RELATIVE)
  end
  (0..1).each do |yd|
    sketch << Positioning.new(center_top_x+scale(398).first,center_top_y-scale(15-yd).first)
    sketch << LineTo.new(*scale(45,0),Command::RELATIVE)
  end


end

s = Sketch.new(Laser.new(power: 1000))

s << FeedRate.new(1000)
wing(s,0,70,RIGHT)
wing(s,0,70,LEFT)
heck(s,-80,30,RIGHT)
heck(s,-80,30,LEFT)
body(s,-120,-10)




s.simulate("#{__FILE__[0..-4]}.pdf")
# s.run
