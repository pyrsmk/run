module Run
  class Task
    # @param &block [Proc]
    def initialize(&block)
      if !block.is_a?(Proc)
        raise ArgumentError.new("'block' must be a Proc")
      end
      @block = block
    end

    # @param arguments [Array]
    # @param options [Hash]
    # @return [void]
    def run(arguments, options)
      if options.size == 0
        @block.call *arguments
      else
        @block.call *arguments, **options
      end
      nil
    end
  end
end
