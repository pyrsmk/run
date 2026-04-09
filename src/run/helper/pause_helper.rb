# frozen_string_literal: true

module Run
  module Helper
    class PauseHelper
      DEFAULT_TEXT = "Press enter to continue"

      # @param text [String]
      def initialize(text = DEFAULT_TEXT)
        raise ArgumentError.new("'text' must be a String") if !text.is_a?(String)

        @text = text
      end

      # @return [void]
      def run
        print "#{@text}..."
        STDIN.gets("\n")
      end
    end
  end
end