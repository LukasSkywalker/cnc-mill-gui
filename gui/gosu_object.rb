class GosuObject
  attr_accessor :name, :onclick

  UP = :up
  DOWN = :down
  LEFT = :left
  RIGHT = :right
  CHANGED = :changed
  KEY = :key


  def initialize(name,left,bottom,right,top)
    @name = name
    @left,@bottom,@right,@top = left,bottom,right,top
    @state = {LEFT=>false,RIGHT=>false,KEY=>[],CHANGED=>nil}
    @stop_request = false
  end

  def active?
    if @stop_request
      @stop_request = false
      return false
    end
    @state[LEFT]
  end

  def delete?
    @state[RIGHT] && @state[KEY].include?(:ctrl)
  end

  def stop
    @stop_request = true
  end

  def onclick(id,state)
    return handle_key(id,state) unless @state.has_key?(id)
    case state
    when DOWN
      @state[CHANGED] = id if !@state[id]
      @state[id] = true
    when UP
      @state[CHANGED] = id if @state[id]
      @state[id] = false
    end
    puts state.inspect
  end

  def handle_key(key,state)
    case state
    when DOWN
      @state[KEY] << key
    when UP
      @state[KEY].delete(key)
    end      
  end

  def update(x,y)
    active?
    @state[CHANGED] = nil if @state[CHANGED]  
  end

  def overlay?(x,y)
    (x>@left&&x<@right) && (y>@bottom&&y<@top)
  end
end