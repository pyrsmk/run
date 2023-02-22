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
      # E.g. `Bold` should run before `Italic`.
      tag = Code.new(
              Italic.new(
                Bold.new(@string)
              )
            )
      tag.to_ansi
    end
  end
end
