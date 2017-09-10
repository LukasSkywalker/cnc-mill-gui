require_relative 'button'
require_relative 'push_button'
require_relative 'gosu_component'

class Controls <  GosuComponent
  def initialize(name,left=0,top=0,right=0,bottom=0)
    super(name,left,top,right,bottom)
    @buttons = {}
  end

  def update(x,y)
    update_buttons(x,y)
    draw()
  end

  def draw
    Gosu.draw_rect(@left,@top, @right-@left,@bottom-@top, Gosu::Color::GRAY,-999)
    all_buttons.each{|b| b.draw}
  end

  def add_button(button, group=:default)
    raise 'has to be a button object' unless button.is_a?(Button)
    button.x += @left
    button.y += @top
    @buttons[group] ||= []
    @buttons[group] << button
  end

  def get_active_button(group = :default)
    @buttons[group].reject{|obj| !obj.active?}.first
  end

  def update_buttons(x,y)
    @buttons.each do |key, btns|
      to_delete = []
      request = false
      btns.each do |btn|
        btn.update(x,y)
        if btn.delete_request
          to_delete << btn
        elsif btn.selfautocracy_request
          request = true
        end
      end
      to_delete.each do |btn|
        @buttons[key].delete(btn)
      end
      if request
        unique = true
        @buttons[key].each do |btn|
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

  def click_action(id,pos)
    return unless id==LEFT
    b = all_buttons.find{|btn| btn.overlay?(*pos)}
    b.onclick(id,DOWN,pos) if b
  end

  def button_up_action(id,pos)
    return unless id==LEFT
    b = all_buttons.find{|btn| btn.overlay?(*pos)}
    b.onclick(id,UP,pos) if b
  end

  def overlay?(x,y)

    all_buttons.any?{|btn| btn.overlay?(x,y)}
  end

  def all_buttons
    @buttons.values.reduce([]){|m,b| m.concat(b)}
  end

end