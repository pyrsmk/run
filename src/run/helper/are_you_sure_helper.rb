module Run
  module Helper
    class AreYouSureHelper
      # @param message [String]
      def initialize(message = "Are you sure?")
        raise ArgumentError.new("'message' must be a String") if !message.is_a?(String)
        @message = message
      end

      # @return [void]
      def run
        puts "#{@message.yellow.bold} [yN]"
        raise Run::Error::Aborted.new unless answer == "y"
      end

      private

      # @return [String, Nil]
      def answer
        STDIN.gets.chomp.downcase.chars.first
      end
    end
  end
end
