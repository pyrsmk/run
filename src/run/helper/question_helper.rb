# frozen_string_literal: true

require "tty-prompt"

module Run
  module Helper
    class QuestionHelper
      # @param question [String]
      # @param regex [Regexp, Nil]
      # @param default [String, Nil]
      def initialize(question, regex = nil, default: nil)
        raise ArgumentError.new("'question' must be a String") if !question.is_a?(String)
        raise ArgumentError.new("'default' must be a String") if !default.nil? && !default.is_a?(String)

        @question = question
        @regex = regex
        @default = default
      end

      # @return [any]
      def run
        TTY::Prompt.new.ask(@question) do |config|
          config.required true
          if @default
            config.default @default
          end
          if @regex
            config.validate @regex
          end
        end
      end
    end
  end
end
