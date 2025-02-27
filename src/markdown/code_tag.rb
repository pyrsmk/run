require_relative "./abstract_tag"

module Markdown
  class CodeTag
    include AbstractTag

    protected

    # @return [Array<String>]
    def tokens
      ["`"]
    end

    # @param string [String]
    # @return [String]
    def convert(string)
      string.cyan
    end
  end
end
