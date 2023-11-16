require_relative "./abstract_helper"

module Run
  module Helper
    class AreYouSureHelper < AbstractHelper
      def initialize
      end

      # @return [String]
      def name
        "are_you_sure?"
      end

      # @param text [String]
      # @return [void]
      def run(*args)
        text = args[0] || "Are you sure?"
        if !text.is_a?(String)
          raise ArgumentError.new("'text' must be a String")
        end
        puts "#{text.yellow.bold} [yN]"
        answer = STDIN.gets.chomp.downcase.chars.first
        raise Run::Error::Aborted.new unless answer == "y"
        nil
      end
    end
  end
end
