module Run
  module Helper
    class CatchInterruptionHelper
      # @param command [String]
      # @param &block [Proc]
      def initialize(command, &block)
        @command = command
        @block = block
      end

      # @return [void]
      def run
        Run::Task::SystemTask.new(@command).run
      rescue Interrupt
      ensure
        @block&.call
      end
    end
  end
end
