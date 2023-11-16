# https://gist.github.com/fnky/458719343aabd01cfb17a3a4f7296797
class String
  @@styles = {
    :bold              => "1",
    :dim               => "2",
    :italic            => "3",
    :underline         => "4",
    :inverse           => "7",
    :strikethrough     => "9",
    :fg_black          => "30",
    :fg_red            => "31",
    :fg_green          => "32",
    :fg_yellow         => "33",
    :fg_blue           => "34",
    :fg_magenta        => "35",
    :fg_cyan           => "36",
    :fg_white          => "37",
    :fg_bright_black   => "30;1",
    :fg_bright_red     => "31;1",
    :fg_bright_green   => "32;1",
    :fg_bright_yellow  => "33;1",
    :fg_bright_blue    => "34;1",
    :fg_bright_magenta => "35;1",
    :fg_bright_cyan    => "36;1",
    :fg_bright_white   => "37;1",
  }

  # To be able to handle more styles (with method chaining) we should refactor this.
  def stylize(style)
    "\033[#{@@styles[style.to_sym]}m#{self}\033[0m"
  end

  def bold;              stylize(:bold); end
  def dim;               stylize(:dim); end
  def italic;            stylize(:italic); end
  def underline;         stylize(:underline); end
  def inverse;           stylize(:inverse); end
  def strikethrough;     stylize(:strikethrough); end
  def black;             stylize(:fg_black); end
  def red;               stylize(:fg_red); end
  def green;             stylize(:fg_green); end
  def yellow;            stylize(:fg_yellow); end
  def blue;              stylize(:fg_blue); end
  def magenta;           stylize(:fg_magenta); end
  def cyan;              stylize(:fg_cyan); end
  def white;             stylize(:fg_white); end
  def bright_black;      stylize(:fg_bright_black); end
  def bright_red;        stylize(:fg_bright_red); end
  def bright_green;      stylize(:fg_bright_green); end
  def bright_yellow;     stylize(:fg_bright_yellow); end
  def bright_blue;       stylize(:fg_bright_blue); end
  def bright_magenta;    stylize(:fg_bright_magenta); end
  def bright_cyan;       stylize(:fg_bright_cyan); end
  def bright_white;      stylize(:fg_bright_white); end
end
