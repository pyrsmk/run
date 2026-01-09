# frozen_string_literal: true

module Run
  module Helper
    class PauseHelper
      # @return [void]
      def run
        STDIN.gets("\n")
      end
    end
  end
end
