class ObjectManager
  def initialize()
    @objects = {}
    @buttons = {}
  end

  def update(x,y)
    update_objects(x,y)
    update_buttons(x,y)
  end

  def update_objects(x,y)
    @objects.each do |k,objs|
      to_delete = []
      objs.each do |obj|
        obj.update(x,y)
        to_delete << obj if obj.delete?
      end
      to_delete.each do |obj|
        objs.delete(obj)
      end
    end
  end
  
  def update_buttons(x,y)
    @buttons.each do |k,btns|
      to_delete = []
      request = false
      btns.each do |btn|
        btn.update(x,y)
        if btn.delete?
          to_delete << btn
        elsif btn.selfautocracy_request
          request = true
        end
      end
      to_delete.each do |btn|
        btns.delete(btn)
      end
      if request
        unique = true
        btns.each do |btn|
          btn.deactivate
          if btn.selfautocracy_request && unique
            btn.activate
            btn.selfautocracy_request = false
            unique = false
          end
        end
      end
    end
  end

  def add(new_object, z=0)
    raise 'has to be a gosu object' unless new_object.is_a?(GosuObject)
    @objects[z] ||= []
    @objects[z] << new_object
  end

  def add_button(button, group = :default)
    raise 'has to be a button object' unless button.is_a?(Button)
    add(button,-999)
    @buttons[group] ||= []
    @buttons[group] << button
  end

  def has_overlay?(x, y)
    keys = @objects.keys.sort.reverse
    keys.each do |k|
      @objects[k].each do |obj|
        return true if obj.overlay?(x,y)
      end
    end
    false
  end

  def get_overlay_object(x, y)
    keys = @objects.keys.sort.reverse
    keys.each do |k|
      @objects[k].each do |obj|
        return obj if obj.overlay?(x,y)
      end
    end
    nil
  end
end