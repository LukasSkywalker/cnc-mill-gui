require 'byebug'
class GosuComponent
  attr_accessor :name,:draw
  attr_reader :last_modified, :delete_request

  UP = :up
  DOWN = :down
  DOWN2 = :down2
  LEFT = :left
  RIGHT = :right
  CHANGED = :changed
  KEY = :key

  def initialize(name,left=0,top=0,right=0,bottom=0)
    @name = name
    @left,@bottom,@right,@top = left,bottom,right,top
    @state = {LEFT=>false,RIGHT=>false,CHANGED=>nil, :ctrl => nil}
    @last_modified = Time.now
    @edit_mode = false
    @draw = true
    @delete_request = false
  end

  def active?
    # @state[LEFT]
    @edit_mode
  end

  def onclick(id,state,pos)
    # return handle_key(id,state) unless @state.has_key?(id)
    case state
    when DOWN
      @state[CHANGED] = id if !@state[id]
      @state[id] = true
      click_action(id,pos)
    when DOWN2
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
    @edit_mode = true
  end

  def doubleclick_action(id,pos)
    puts "#{self.class}: #{id}"  
  end
  
  def button_up_action(id,pos)
    puts "#{self.class}: #{id} off"
    case id
    when GosuComponent::LEFT
      @edit_mode = false
    when GosuComponent::RIGHT
      @delete_request = @state[:ctrl]
    end
  end

  def update(x,y)
    active?
    @state[CHANGED] = nil if @state[CHANGED]  
    draw()
  end

  def draw
    raise 'not implemented'
  end

  def draw?
    @draw
  end

  def overlay?(x,y)
    @draw && (x>@left&&x<@right) && (y<@bottom&&y>@top)
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