module EventHandler
  DOUBLE_CLICK_TIME_THRESHOLD = 0.3 
  @current_object = nil
  @last_leftclick = nil

  def set_current_object(current_object)
    return until current_object
    @current_object = current_object
  end

  def unset_current_object
    @current_object = nil
  end

  def button_down(id)
    case id
    when Gosu::MsLeft
      @last_leftclick ||= Time.new(0)
      time = Time.now
      df = time-@last_leftclick
      puts df
      @last_leftclick = time
      if df < DOUBLE_CLICK_TIME_THRESHOLD
        run_mouse_handler(GosuObject::LEFT, GosuObject::DOWN2)
      else
        run_mouse_handler(GosuObject::LEFT, GosuObject::DOWN)
      end
    when Gosu::MsRight
      run_mouse_handler(GosuObject::RIGHT, GosuObject::DOWN)
    when Gosu::KbEscape
      self.close
    when Gosu::KB_LEFT_CONTROL
      run_mouse_handler(:ctrl, GosuObject::DOWN)
    end
  end

  def button_up(id)
    case id
    when Gosu::MsLeft
      run_mouse_handler(GosuObject::LEFT, GosuObject::UP)
    when Gosu::MsRight
      run_mouse_handler(GosuObject::RIGHT, GosuObject::UP)
    when Gosu::KB_LEFT_CONTROL
      run_mouse_handler(:ctrl, GosuObject::UP)
    end
  end

  def run_mouse_handler(id, state)
    set_current_object(@object_manager.get_overlay_object(self.mouse_x, self.mouse_y))
    if !@current_object
    end
    if @current_object
      @current_object.onclick(id, state)
      # puts @current_object.inspect
      @current_object = nil unless @current_object.active?
    end
  end
end