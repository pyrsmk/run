module Run
  module Helper
    class WaitForInterruptionHelper
      # @param &block [Proc]
      def initialize(&block)
        @block = block
      end

      # @return [void]
      def run
        STDIN.gets while true
        @block.call
      end
    end
  end
end
