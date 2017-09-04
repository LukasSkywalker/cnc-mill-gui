require_relative 'gosu_composition'
require_relative 'point'

class Picture < GosuComposition
  def initialize(fname)
    super('Polygon',Point.new(0,0), Point.new(0,0))
    @image = Gosu::Image.new(fname)

    @points = {:left_top => Point.new(0,0),
      :right_bottom=>Point.new(@image.width,@image.height)}
  end

  def set_shift(x,y)
    @points.each do |k,point|
      point.shift(x,y)
    end
  end

  def update(x,y)
    return unless @draw
    get_active_points().each{|p| p.update(x,y)}
    update_shift()
    draw()
  end

  def draw
    diff = @points[:right_bottom]-@points[:left_top]
    scale_x = diff.x.to_f/@image.width
    scale_y = diff.y.to_f/@image.height
    # scale = scale_x < scale_y ? scale_x : scale_y
    @image.draw(@points[:left_top].x,@points[:left_top].y, -9999, scale_x,scale_y)
  end

  def get_instance_points
    [@points[:right_bottom]].reject(&:nil?).sort().reverse()
  end

  def get_dynamic_points
    [@points[:left_top], @center,@scale_point]
  end


  def get_balance_point
    @points[:left_top] + ((@points[:right_bottom]-@points[:left_top])/2.0)
  end



end