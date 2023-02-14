require_relative "./string"

class Markdown
  def initialize(string)
    @string = string
  end

  def to_ansi
    # Apply private methods onto string.
    private_methods(false).reject{ |name| name == :initialize }
                          .reduce(@string) do |string, method|
                            send(method, string)
                          end
  end

  private

  def bold(string)
    string.gsub(/([^*_])[*_]{2}([^*_]+)[*_]{2}([^*_])/) do
      Regexp.last_match[1] + Regexp.last_match[2].bold + Regexp.last_match[3]
    end
  end

  def code(string)
    string.gsub(/([^`])`([^*_]+)`([^`])/) do
      Regexp.last_match[1] + Regexp.last_match[2].blue.inverse + Regexp.last_match[3]
    end
  end

  def italic(string)
    string.gsub(/([^*_])[*_]{1}([^*_]+)[*_]{1}([^*_])/) do
      Regexp.last_match[1] + Regexp.last_match[2].italic + Regexp.last_match[3]
    end
  end
end
