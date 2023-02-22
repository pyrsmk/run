require_relative "./abstract_tag"
require_relative "../string"

module Markdown
  class Italic
    include AbstractTag

    protected

    def tokens
      ['*', '_']
    end

    def replace_by(string)
      string.italic
    end
  end
end
