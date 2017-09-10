require_relative 'gosu_composition'
require_relative 'point'

class Picture < GosuComposition
  def initialize(fname)
    super('Polygon',Point.new(0,0), Point.new(0,0))
    @image = Gosu::Image.new(fname)

    @points = {:left_top => Point.new(0,0),
      :right_bottom=>Point.new(@image.width,@image.height)}
  end

  def set_pos(left_top, right_bottom, lock_proportion = false)
    complete_positions(left_top, right_bottom)
    @points[:left_top].set_pos(*left_top.to_a)
    @points[:right_bottom].set_pos(*right_bottom.to_a)
    update_proportion() if lock_proportion
    self
  end

  def complete_positions(left_top,right_bottom)
    ratio =@image.width / @image.height.to_f
    if left_top.x.nan? || right_bottom.x.nan?
      wdith = ratio*(right_bottom.y-left_top.y)
      left_top.set_pos(right_bottom.x-wdith,left_top.y) if left_top.x.nan?
      right_bottom.set_pos(left_top.x+wdith,right_bottom.y) if right_bottom.x.nan?
    elsif left_top.y.nan? || right_bottom.y.nan?
      height = (right_bottom.x-left_top.x)/ratio
      left_top.set_pos(left_top.x,right_bottom.y-height) if left_top.y.nan?
      right_bottom.set_pos(right_bottom.x,left_top.y+height) if right_bottom.y.nan?
    end
  end

  def update_proportion
    diff = @points[:right_bottom]-@points[:left_top]
    ratio = @image.width / @image.height.to_f
    return if ratio == (diff.x / diff.y)
    if (diff.x / diff.y).abs > ratio
      @points[:right_bottom].set_pos(@points[:right_bottom].x,diff.y/ratio)
    else
      @points[:right_bottom].set_pos(diff.y*ratio,@points[:right_bottom].y)
    end
  end

  def set_shift(x,y)
    @points.each do |k,point|
      point.shift(x,y)
    end
    self
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
    [@points[:left_top], @center]
  end


  def get_balance_point
    @points[:left_top] + ((@points[:right_bottom]-@points[:left_top])/2.0)
  end



end