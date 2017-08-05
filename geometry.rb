require 'beziercurve'
require 'unit_quaternion'

module Geometry

  FMT = "%0.5f"

  def bezier(accuracy, dim1, dim2, *control_points)
    throw "Cannot create curve with less than 3 control points #{control_points.inspect}" unless control_points.length>3
    throw 'dim1 should be X,Y or Z' unless ['X','Y','Z'].include?(dim1)
    throw 'dim2 should be X,Y or Z' unless ['X','Y','Z'].include?(dim2)
    bez = Bezier::Curve.new(*control_points)
    xd = control_points[-1][0]-control_points[0][0]
    yd = control_points[-1][1]-control_points[0][1]
    dist = Math.sqrt(xd*xd + yd*yd)
    g_bez = []
    (0..1).step(accuracy/dist.to_f).each do |p|
      g_bez << [bez.point_on_curve(p).x, bez.point_on_curve(p).y]
    end
    g_code = gcode_from2d(g_bez,dim1,dim2)
    g_code
  end

  def gcode_from2d(data2d, dim1, dim2)
    throw 'dim1 should be X,Y or Z' unless ['X','Y','Z'].include?(dim1)
    throw 'dim2 should be X,Y or Z' unless ['X','Y','Z'].include?(dim2)

    coord = data2d.map{|p| sprintf("%s#{FMT} %s#{FMT}",dim1,p[0],dim2,p[1])}.join("\n")
    coord
  end

  
  def gcode(data3d)
    g_code = data3d.map{|p| sprintf("X#{FMT} Y#{FMT} Z#{FMT}",*p)}.join("\n")
    g_code
  end
  
  def circle(start_point=[1.0,0], center=[0,0], angle=360.0, dir='clock')
    throw 'direction must be ''clock'' or ''cclock''' unless ['clock','cclock'].include?(dir)
    start_point[2]=center[2] = 0.0
    start_point,center = Vector[*start_point[0..2]], Vector[*center[0..2]]
    axis = dir=='clock' ? Vector[0,0,-1]:Vector[0,0,1]
    quat = UnitQuaternion.fromAngleAxis(Math::PI*angle/180.0, axis)

    to_rot = start_point-center
    end_p = (center+quat.transform(to_rot)).to_a
    rel_center = center-start_point
    
    g_code = sprintf("G02 X#{FMT}Y#{FMT} I#{FMT}J#{FMT}",*rel_center,*end_p)
    g_code
  end

  def circle3d(start_point=[1.0,0,0], center=[0,0,0], angle=360, axis=[0,0,1], accuracy=1.0, dir='clock')
    throw 'direction must be ''clock'' or ''cclock''' unless ['clock','cclock'].include?(dir)
    axis = axis.map{|v| -v} if dir=='clock'
    quat = UnitQuaternion.fromAngleAxis(Math::PI*accuracy/180.0, Vector[*axis])
    start_point,center = Vector[*start_point[0..2]], Vector[*center[0..2]]

    to_rot = start_point-center
    rel_center = center-start_point
    coord = [(center+to_rot).to_a]

    (0..angle).step(accuracy).each do |i|
      to_rot = quat.transform(to_rot)
      coord << (center+to_rot).to_a
    end
    g_code = gcode(coord)
    g_code
  end

end
