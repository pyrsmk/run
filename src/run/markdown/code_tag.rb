require_relative "./abstract_tag"
require_relative "../string"

module Markdown
  class Code
    include AbstractTag

    protected

    def tokens
      ['`']
    end

    def replace_by(string)
      string.cyan
    end
  end
end
