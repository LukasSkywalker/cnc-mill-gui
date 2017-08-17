class GosuObject
  attr_accessor :name, :onclick, :active

  def initialize(name,left,bottom,right,top)
    @name = name
    @left,@bottom,@right,@top = left,bottom,right,top
    @state = :off
    @active = false
  end

  def active?
    @active
  end

  def activate
    @active = true
  end

  def deactivate
    @active = false
  end

  def onclick(id,direction)
    case direction
    when :down
      @state = :on
      activate
    when :up
      @state = :off
      deactivate
    end
    puts @state.inspect
    puts direction
  end

  def update(board,x,y)
  end

  def overlay?(x,y)
    (x>@left&&x<@right) && (y>@bottom&&y<@top)
  end
end