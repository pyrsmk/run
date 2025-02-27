require_relative "./bold_tag"
require_relative "./code_tag"
require_relative "./italic_tag"

module Markdown
  class Engine
    def initialize(string)
      @string = string
    end

    def to_ansi
      # The tags are ordered by priority.
      # For example: `Bold` should run before `Italic`.
      CodeTag.new(ItalicTag.new(BoldTag.new(@string))).to_ansi
    end
  end
end
