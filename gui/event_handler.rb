module EventHandler
  @current_object = nil

  def set_current_object(current_object)
    @current_object = current_object
  end

  def unset_current_object
    @current_object = nil
  end

  def position_update
    if @current_object
      @current_object.onposition_update.call(self.mouse_x,self.mouse_y)
    end
  end

  def button_down(id)
    case id
    when Gosu::MsLeft
      #run_mouse_handler(id, :down)
      @drawing = true
      @paths << Path.new
    when Gosu::KbEscape
      self.close
    end
  end

  def button_up(id)
    case id
    when Gosu::MsLeft
      #run_mouse_handler(id, :up)
      @drawing = false
    end
  end

  def run_mouse_handler(id, direction)
    object = get_overlay_object(self.mouse_x, self.mouse_y)
    if object
      object.onclick.call(self, id, direction)
    end
  end
end