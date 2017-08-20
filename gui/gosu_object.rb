class GosuObject
  attr_accessor :name,

  UP = :up
  DOWN = :down
  DOWN2 = :down2
  LEFT = :left
  RIGHT = :right
  CHANGED = :changed
  KEY = :key

  def initialize(name,left,bottom,right,top)
    @name = name
    @left,@bottom,@right,@top = left,bottom,right,top
    @state = {LEFT=>false,RIGHT=>false,KEY=>[],CHANGED=>nil,:finished=>false}
    @stop_request = false
    @last_modified = Time.now    
  end

  def active?
    if @stop_request
      @stop_request = false
      return false
    end
    @state[LEFT]
  end

  def finish
    @state[:finished] = true
  end

  def finished?
    @state[:finished]
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
    when DOWN2
      puts'down2'
      @state[CHANGED] = DOWN2 if !@state[id]
      @state[id] = true
    when UP
      @state[CHANGED] = id if @state[id]
      @state[id] = false
    end
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