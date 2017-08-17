class Path
  attr_accessor :points

  def initialize()
    @points = []
  end

  def pairwise
    @points.each_cons(2).to_a
  end

  def draw
    pairwise.each do |one, two|
		  Gosu.draw_line	one.x, one.y, Gosu::Color::GREEN, two.x, two.y, Gosu::Color::GREEN
		end
  end
end