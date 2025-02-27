require_relative "./abstract_tag"

module Markdown
  class BoldTag
    include AbstractTag

    protected

    # @return [Array<String>]
    def tokens
      ["**", "__"]
    end

    # @param string [String]
    # @return [String]
    def convert(string)
      string.bold
    end
  end
end
