require_relative "./abstract_helper"

module Run
  module Helper
    class PauseHelper < AbstractHelper
      def initialize
      end

      # @return [String]
      def name
        "pause"
      end

      # @return [void]
      def run
        $stdin.gets("\n")
        nil
      end
    end
  end
end
