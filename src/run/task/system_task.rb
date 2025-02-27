module Run
  module Task
    class SystemTask
      # @param command [String]
      def initialize(command)
        @command = command
      end

      # @param arguments [Array] (unused)
      # @param options [Hash] (unused)
      # @return [void]
      def run(*arguments, **options)
        puts ">".bright_blue + " #{@command}".bright_white
        puts

        case system(@command)
        when false
          puts "The command has exited with return code: #{$?.exitstatus}.".magenta
          puts
          raise Interrupt.new
        when nil
          puts "The command has failed.".magenta
          puts
          raise Interrupt.new
        end

        puts
      end
    end
  end
end
