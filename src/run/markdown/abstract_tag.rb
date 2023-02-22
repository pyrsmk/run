module Markdown
  module AbstractTag
    def initialize(value)
      case value
      when String
        @string = value
      when AbstractTag
        @tag = value
      else
        raise "Invalid value of '#{value.class.name}' class"
      end
    end

    def to_ansi
      string = @string || @tag.to_ansi
      pattern = Regexp.new(
        "(^|.+?)" \
        "(?:#{tokens.map{ |token| "\\" + token.chars.join("\\") }.join('|')})" \
        "(.+?)" \
        "(?:#{tokens.map{ |token| "\\" + token.chars.join("\\") }.join('|')})" \
        "($|.+)"
      )

      loop do
        string = string.sub(pattern) do
          Regexp.last_match[1] + replace_by(Regexp.last_match[2]) + Regexp.last_match[3]
        end
        break if !Regexp.last_match
      end

      string
    end

    protected

    def tokens
      raise "Not implemented"
    end

    def replace_by(string)
      raise "Not implemented"
    end
  end
end
