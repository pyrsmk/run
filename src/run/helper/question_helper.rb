require "tty-prompt"

module Run
  module Helper
    class QuestionHelper
      # @param question [String]
      # @param regex [Regexp, Nil]
      def initialize(question, regex = nil)
        raise ArgumentError.new("'question' must be a String") if !question.is_a?(String)

        @question = question
        @regex = regex
      end

      # @return [any]
      def run
        TTY::Prompt.new.ask(@question) do |config|
          config.required true
          if @regex
            config.validate @regex
          end
        end
      end
    end
  end
end
