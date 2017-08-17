class GosuObject
  attr_accessor :name, :onclick

  def initialize(name,left,bottom,right,top)
    @name = name
    @left,@bottom,@right,@top = left,bottom,right,top
    @onclick = -> { }
    @onposition_update = -> { }
  end

  def overlay?(x,y)
    (x>@left&&x<@right) && (y>bottom&&y<top)
  end
end

class WindowManager
  def initialize()
    @objects = {}
  end

  def add(new_object, z=0)
    raise 'has to be a gosu object' unless new_object.is_a?(GosuObject)
    if @objects.key?(z)
      @objects[z]<<new_object
    else
      @objects[z] = [new_object]
    end
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