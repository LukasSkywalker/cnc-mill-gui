require_relative 'command'

class Letter < Command
  def initialize(letter, letter_size: 1)
    @letter = letter
    @is_relative = is_relative
    @letter_size = 1
  end

  def to_gcode(tool)
    old_x,old_y = tool.position
    strokes = send('letter_' + @letter)
    commands = []
    strokes.each do |x1, y1, x2, y2|
      commands << tool.off
      commands << "G01 X#{old_x + x1} Y#{old_y + y1}"
      commands << tool.on
      commands << "G01 X#{old_x + x2} Y#{old_y + y2}"
    end

    tool.update_position(old_x + 0.75*@letter_size, old_y)
    [commands]
  end

  def to_prawn(tool, pdf)
    old_x,old_y = tool.position
    strokes = send('letter_' + @letter)
    pdf.stroke_color '000000'
    strokes.each do |x1, y1, x2, y2|
      pdf.line([[x1, y1], [x2, y2]])
    end
    pdf.stroke
    tool.update_position(old_x + 0.75*@letter_size, old_y)
  end


  def get_pos(tool)
    if @is_relative
      [tool.position.first + LETTER_WIDTH, tool.position.last]
    else
      [@x + LETTER_WIDTH, @y]
    end
  end

  def quarter_up; 0.75 * @letter_size; end
def half_up; 0.5 * @letter_size; end
def quarter_down; 0.25 * @letter_size; end
def half_right; 0.25 * @letter_size; end
def quarter_left; 0.125 * @letter_size; end
def quarter_right; 0.325 * @letter_size; end
def right; 0.5 * @letter_size; end
def up; 1 * @letter_size; end
def down; 0 * @letter_size; end
def left; 0 * @letter_size; end

def letter_a
  [[left, down, half_right, up], [half_right, up, right, down], [quarter_left, half_up, quarter_right, half_up]]
end

def letter_c
  [[right, down, left, down], [left, down, left, up], [left, up, right, up]]
end

def letter_e
  [[right, down, left, down], [left, down, left, up], [left, up, right, up], [left, half_up, right, half_up]]
end

def letter_f
  [[left, down, left, up], [left, up, right, up], [left, half_up, right, half_up]]
end

def letter_u
  [[left, up, left, down], [left, down, right, down], [right, down, right, up]]
end

def letter_k
  [[left, up, left, down], [left, half_up, right, up], [left, half_up, right, down]]
end
end
