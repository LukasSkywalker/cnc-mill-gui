require_relative 'command'

class Letter < Command
  def initialize(letter, letter_size: 1)
    @letter = letter
    @is_relative = is_relative
    @letter_size = letter_size
  end

  def to_gcode(tool)
    old_x,old_y = tool.position
    strokes = get_letters[@letter.to_sym]
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
    strokes = get_letters[@letter.to_sym]
    pdf.stroke_color '000000'
    strokes.each do |x1, y1, x2, y2|
      pdf.line([[old_x + x1, old_y + y1], [old_x + x2, old_y + y2]])
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

  def quarter_top; 0.75 * @letter_size; end
  def half_top; 0.5 * @letter_size; end
  def quarter_bottom; 0.25 * @letter_size; end
  def half_right; 0.25 * @letter_size; end
  def quarter_left; 0.125 * @letter_size; end
  def quarter_right; 0.325 * @letter_size; end
  def right; 0.5 * @letter_size; end
  def top; 1 * @letter_size; end
  def bottom; 0 * @letter_size; end
  def left; 0 * @letter_size; end

  def get_letters
    empty = [[left, top, right, top], [right, top, right, bottom], [right, bottom, left, bottom], [left, bottom, left, top], [right, top, left, bottom], [left, top, right, bottom]]
    {
      'a': [[left, bottom, half_right, top], [half_right, top, right, bottom], [quarter_left, half_top, quarter_right, half_top]],
      'b': [[left, bottom, left, top], [left, top, half_right, top], [half_right, top, half_right, half_top], [left, half_top, right, half_top], [right, half_top, right, bottom], [right, bottom, left, bottom]],
      'c': [[right, bottom, left, bottom], [left, bottom, left, top], [left, top, right, top]],
      'd': [[left, bottom, left, top], [left, top, right, half_top], [right, half_top, left, bottom]],
      'e': [[right, bottom, left, bottom], [left, bottom, left, top], [left, top, right, top], [left, half_top, right, half_top]],
      'f': [[left, bottom, left, top], [left, top, right, top], [left, half_top, right, half_top]],
      'g': [[right, top, left, top], [left, top, left, bottom], [left, bottom, right, bottom], [right, bottom, right, half_top], [right, half_top, half_right, half_top]],
      'h': [[left, top, left, bottom], [left, half_top, right, half_top], [right, top, right, bottom]],
      'i': [[half_right, top, half_right, bottom]],
      'j': [[right, top, right, bottom], [right, bottom, left, bottom]],
      'k': [[left, top, left, bottom], [left, half_top, right, top], [left, half_top, right, bottom]],
      'l': [[left, top, left, bottom], [left, bottom, right, bottom]],
      'm': [[left, bottom, quarter_left, top], [quarter_left, top, half_right, bottom], [half_right, bottom, quarter_right, top], [quarter_right, top, right, bottom]],
      'n': [[left, bottom, left, top], [left, top, right, bottom], [right, bottom, right, top]],
      'o': [[left, bottom, left, top], [left, top, right, top], [right, top, right, bottom], [right, bottom, left, bottom]],
      'p': [[left, bottom, left, top], [left, top, right, top], [right, top, right, half_top], [right, half_top, left, half_top]],
      'q': [[left, top, right, top], [right, top, right, bottom], [right, bottom, left, bottom], [left, bottom, left, top], [quarter_right, half_top, right, bottom]],
      'r': [[left, bottom, left, top], [left, top, right, top], [right, top, right, half_top], [right, half_top, left, half_top], [left, half_top, right, bottom]],
      's': [[right, top, left, top], [left, top, left, half_top], [left, half_top, right, half_top], [right, half_top, right, bottom], [right, bottom, left, bottom]],
      't': [[left, top, right, top], [half_right, top, half_right, bottom]],
      'u': [[left, top, left, bottom], [left, bottom, right, bottom], [right, bottom, right, top]],
      'v': [[left, top, half_right, bottom], [half_right, bottom, right, top]],
      'w': [[left, top, quarter_left, bottom], [quarter_left, bottom, half_right, top], [half_right, top, quarter_right, bottom], [quarter_right, bottom, right, top]],
      'x': [[left, top, right, bottom], [left, bottom, right, top]],
      'y': [[left, top, half_right, half_top], [right, top, half_right, half_top], [half_right, half_top, half_right, bottom]],
      'z': [[left, top, right, top], [right, top, left, bottom], [left, bottom, right, bottom]]
    }
  end
end
