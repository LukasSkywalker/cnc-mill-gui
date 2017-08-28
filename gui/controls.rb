require_relative 'button'
require_relative 'push_button'
require_relative 'gosu_component'

class Controls <  GosuComponent
  def initialize(name,left=0,bottom=0,right=0,top=0)
    super(name,left,bottom,right,top)
    @buttons = []
  end

  def update(x,y)
    update_buttons(x,y)
    draw()
  end

  def draw
    Gosu.draw_rect(@left,@bottom, @right-@left,@top-@bottom, Gosu::Color::GRAY,-999)
    @buttons.each{|b| b.draw}
  end

  def add_button(button)
    raise 'has to be a button object' unless button.is_a?(Button)
    button.x += @left
    button.y += @top
    @buttons << button
  end

  def get_active_button(group = :default)
    @buttons[group].reject{|obj| !obj.active?}.first
  end

  def update_buttons(x,y)
    to_delete = []
    request = false
    @buttons.each do |btn|
      btn.update(x,y)
      if btn.delete_request
        to_delete << btn
      elsif btn.selfautocracy_request
        request = true
      end
    end
    to_delete.each do |btn|
      @buttons.delete(btn)
    end
    if request
      unique = true
      @buttons.each do |btn|
        btn.deactivate
        if btn.selfautocracy_request && unique
          btn.activate
          btn.selfautocracy_request = false
          unique = false
        end
      end
    end
  end

  def click_action(id,pos)
    return unless id==LEFT
    b = @buttons.find{|btn| btn.overlay?(*pos)}
    b.onclick(id,DOWN,pos) if b
  end

  def button_up_action(id,pos)
    return unless id==LEFT
    b = @buttons.find{|btn| btn.overlay?(*pos)}
    b.onclick(id,UP,pos) if b
  end

  def overlay?(x,y)
    @buttons.any?{|btn| btn.overlay?(x,y)}
  end

end