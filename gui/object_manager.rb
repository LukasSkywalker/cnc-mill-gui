class ObjectManager
  def initialize()
    @objects = {}
  end

  def update(x,y)
    @objects.each do |k,objs|
      to_delete = []
      objs.each do |obj|
        obj.update(x,y)
        to_delete<<obj if obj.delete?
      end
      to_delete.each do |obj|
        objs.delete(obj)
      end
    end
  end

  def add(new_object, z=0)
    raise 'has to be a gosu object' unless new_object.is_a?(GosuObject)
    if @objects.key?(z)
      @objects[z]<<new_object
    else
      @objects[z] = [new_object]
    end
  end

  def add_button(button)
    add(button,-999)
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