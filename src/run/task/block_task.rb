module Run
  module Task
    class BlockTask
      # @param &block [Proc]
      def initialize(&block)
        @block = block
      end

      # @param arguments [Array]
      # @param options [Hash]
      # @return [void]
      def run(*arguments, **options)
        if options.size == 0
          @block.call *arguments
        else
          @block.call *arguments, **options
        end
      end
    end
  end
end
