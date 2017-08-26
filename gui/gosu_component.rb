require 'byebug'
class GosuComponent
  attr_accessor :name,:draw
  attr_reader :last_modified

  UP = :up
  DOWN = :down
  DOWN2 = :down2
  LEFT = :left
  RIGHT = :right
  CHANGED = :changed
  KEY = :key

  def initialize(name,left=0,bottom=0,right=0,top=0)
    @name = name
    @left,@bottom,@right,@top = left,bottom,right,top
    @state = {LEFT=>false,RIGHT=>false,KEY=>[],CHANGED=>nil,:finished=>false}
    @last_modified = Time.now
    @edit_mode = false
    @draw = true
  end

  def active?
    # @state[LEFT]
    @edit_mode
  end

  def delete?
    @state[RIGHT] && @state[KEY].include?(:ctrl)
  end

  def onclick(id,state,pos)
    # return handle_key(id,state) unless @state.has_key?(id)
    case state
    when DOWN
      @state[CHANGED] = id if !@state[id]
      @state[id] = true
      click_action(id,pos)
    when DOWN2
      puts'down2'
      @state[CHANGED] = DOWN2 if !@state[id]
      @state[id] = true
      doubleclick_action(id,pos)
    when UP
      @state[CHANGED] = id if @state[id]
      @state[id] = false
      button_up_action(id,pos)
    end
    self
  end

  def click_action(id,pos)
    return unless id==LEFT
    puts 'gosu_component: click on'
    @edit_mode = true
  end
  def doubleclick_action(id,pos)    
  end
  def button_up_action(id,pos)
    puts 'click off'
    return unless id==LEFT
    puts 'click off'
    @edit_mode = false
  end

  def update(x,y)
    active?
    @state[CHANGED] = nil if @state[CHANGED]  
    draw()
  end

  def draw
    raise 'not implemented'
  end

  def overlay?(x,y)
    (x>@left&&x<@right) && (y>@bottom&&y<@top)
  end

  def <=>(other)
    if other.is_a?(GosuComponent)
      @last_modified <=> other.last_modified
    else
      @last_modified <=> other
    end
  end
  
  def >(other)
    if other.is_a?(GosuComponent)
      @last_modified > other.last_modified
    else
      @last_modified > other
    end
  end
  
  def <(other)
    if other.is_a?(GosuComponent)
      @last_modified < other.last_modified
    else
      @last_modified < other
    end
  end

end