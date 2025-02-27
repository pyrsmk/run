require_relative "./abstract_tag"

module Markdown
  class ItalicTag
    include AbstractTag

    protected

    # @return [Array<String>]
    def tokens
      ["*", "_"]
    end

    # @param string [String]
    # @return [String]
    def convert(string)
      string.italic
    end
  end
end
