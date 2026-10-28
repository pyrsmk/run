# frozen_string_literal: true

module Run
  module Task
    class BlockTask
      # @param &block [Proc]
      def initialize(&block)
        @block = block
      end

      # @return [Boolean]
      def accepts_keywords?
        @block.parameters.any?{ |type, _| [:key, :keyreq, :keyrest].include?(type) }
      end

      # @param arguments [Array]
      # @param options [Hash]
      # @return [void]
      def run(*arguments, **options)
        @block.call(*arguments, **options)
      end
    end
  end
end
