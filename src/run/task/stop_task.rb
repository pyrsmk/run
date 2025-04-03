module Run
  module Task
    class StopTask
      # @param command [String]
      def initialize(command)
        @command = command
      end

      # @return [void]
      def run
        if !Run::Core::Registry[@command]
          raise Run::Error::NonRunningCommand.new("Unknown running '#{@command}' command")
        end
        Process.kill("TERM", Run::Core::Registry[@command])
        Run::Core::Registry.delete(@command)
      end
    end
  end
end
