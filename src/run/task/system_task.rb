# frozen_string_literal: true

module Run
  module Task
    class SystemTask
      # @param command [String]
      # @param detach [Boolean]
      def initialize(command, detach: false)
        @command = command
        @detach = detach
      end

      # @return [void]
      def run
        puts ">".bright_blue + " #{@command}".bright_white
        puts

        if @detach
          Run::Core::Registry[@command] = spawn(@command, in: "/dev/null")
          puts
          return
        end

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
