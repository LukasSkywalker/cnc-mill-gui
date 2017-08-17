module EventHandler
  @current_object = nil

  def set_current_object(current_object)
    return until current_object
    @current_object = current_object
    @current_object.activate
  end

  def unset_current_object
    puts "unset"
    @current_object.deactivate
    @current_object = nil
  end

  def button_down(id)
    case id
    when Gosu::MsLeft
      run_mouse_handler(id, :down)
    when Gosu::KbEscape
      self.close
    end
  end

  def button_up(id)
    case id
    when Gosu::MsLeft
      run_mouse_handler(id, :up)
    end
  end

  def run_mouse_handler(id, direction)
    if !@current_object
      set_current_object(@object_manager.get_overlay_object(self.mouse_x, self.mouse_y))
      puts @current_object.inspect if @current_object
    end
    if @current_object
      @current_object.onclick(id, direction)
      puts @current_object.active?
      unset_current_object if !@current_object.active?
    end
  end
end