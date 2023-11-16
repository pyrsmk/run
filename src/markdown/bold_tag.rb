require_relative "./abstract_tag"

module Markdown
  class Bold
    include AbstractTag

    protected

    def tokens
      ['**', '__']
    end

    def replace_by(string)
      string.bold
    end
  end
end
