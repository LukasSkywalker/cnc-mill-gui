require_relative 'lang'
require_relative 'geometry'
include Geometry

l = Lang.new

=begin
l.set_feed_rate(1000)
# l.set_laser_power(500)
# l.stop_laser
# l.start_laser
l.set_position(20,00)
=end

# =begin
l.pause(10)

l.set_laser_power(1000)

rnd = Random.new
rnd_pos = []

c = 100
RANGE = 100
(1..1000).each do
    rnd_pos << [rnd.rand(RANGE)-RANGE/2.0,rnd.rand(RANGE)-RANGE/2.0]
end
# l.down(5)
R = 60
OFFSET_L = -90/180.0*Math::PI
OFFSET_S = 40/180.0*Math::PI
l.set_feed_rate(1000)
(0..18).map{|p| 20*p/180.0*Math::PI}.each do |d|
    l.stop_laser
    l.set_position(Math.cos(d)*R,Math.sin(d)*R)
    l.start_laser
    b = bezier(0.2,'X','Y',[Math.cos(d)*R,Math.sin(d)*R],
        [Math.cos(d+OFFSET_L)*R*0.95,Math.sin(d+OFFSET_L)*R*0.95],
        [-Math.cos(d+OFFSET_S)*R*0.3,-Math.sin(d+OFFSET_S)*R*0.3],
        [-Math.cos(d)*R,-Math.sin(d)*R])
    l.add_raw(b)
end
l.stop_laser

l.reset
# =end

# for k in 1..6
#     i = 0
#     l.set_feed_rate(750)
#     l.start_laser
#     b = bezier(0.05,'X','Y',[0,0],*rnd_pos)
#     l.add_raw(b)
#     # while i < (2 * Math::PI)
#     #     i = i + 0.1
#     #     l.set_position(i * 9, Math.sin(i) * k)
#     # end
#     l.stop_laser
#     l.set_feed_rate(1000)
#     l.reset
# end
l.stop_laser
# l.print

l.run
