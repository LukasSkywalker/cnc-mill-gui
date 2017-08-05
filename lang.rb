require 'serialport'
require_relative 'serial'

class Lang
  FMT = "%0.5f"
  def initialize()
    @x = 0
    @y = 0
    @z = 0
    @feed_rate = 100

    @spindle_speed = 0
    @spindle_on = false
    @spindle_dir = 'cw'

    @program = ["G21"]
  end

  def engrave_serial(depth)
    @program << "G47 Z#{depth}, R#{depth+0.1}"
  end

  # feed rate in units per minute
  def set_feed_rate(feed_rate)
    @feed_rate = feed_rate
    @program << "F#{@feed_rate}"
  end

  # spindle speed in RPM
  def set_spindle_speed(spindle_speed)
    @spindle_speed = spindle_speed
    @program << "S#{@spindle_speed}"
  end

  def set_laser_power(laser_power)
    #@spindle_speed = spindle_speed
    @program << "S#{laser_power}"
  end

  def start_spindle(clockwise = true)
    if clockwise
      raise StandardError, "Reversing spindle from CCW to CW not allowed" if @spindle_on && @spindle_dir == 'ccw'
      @spindle_on = true
      @spindle_dir = 'cw'
      @program << "M3"
    else
      raise StandardError, "Reversing spindle from CW to CCW not allowed" if @spindle_on && @spindle_dir == 'cw'
      @spindle_on = true
      @spindle_dir = 'ccw'
      @program << "M4"
    end
  end

  def stop_spindle()
    @spindle_on = false
    @program << "M5"
  end

  def start_laser(dynamic_mode = false)
    if dynamic_mode
      @program << "M4"
    else
      @program << "M3"
    end
  end

  def stop_laser()
    @program << "M5"
  end

  def set_position(x, y)
    @x = x
    @y = y
    @program << sprintf("G01 X#{FMT} Y#{FMT}",@x, @y)
  end

  def move(x, y)
    @x = @x + x
    @y = @y + y
    @program << sprintf("G01 X#{FMT} Y#{FMT}",@x, @y)
  end

  def pause(seconds)
    @program << "G04 P#{seconds}"
  end

  def add_raw(code)
    @program.concat(code.split("\n"))
  end

  def reset
    @x = 0
    @y = 0
    @z = 0
    @program << "G01 X0 Y0"
  end

  def down(distance = 2)
    @z = @z - distance
    @program << sprintf("Z#{FMT}",@z)
  end

  def up(distance = 2)
    @z = @z + distance
    @program << sprintf("Z#{FMT}",@z)
  end

  def simulate
    # TODO
  end

  def print
    @program.each do |l|
      puts l
    end
  end

  def run
    run_program(@program)
  end
end
