# frozen_string_literal: true

require "tty-prompt"

module Run
  module Helper
    class YesnoHelper
      VALIDATION = /\A(y(es)?|no?)?\z/i

      # @param question [String]
      # @param default [Boolean, Nil]
      def initialize(question, default: nil)
        raise ArgumentError.new("'question' must be a String") if !question.is_a?(String)
        raise ArgumentError.new("'default' must be a Boolean") if ![nil, true, false].include?(default)

        @question = question
        @default = default
      end

      # @return [Boolean]
      def run
        answer = TTY::Prompt.new.ask("#{@question} #{suffix}") do |config|
          config.required @default.nil?
          config.validate VALIDATION, "Please answer 'y' or 'n'."
        end
        return @default if answer.nil?

        answer.downcase.start_with?("y")
      end

      private

      # @return [String]
      def suffix
        case @default
        when true then "[Yn]"
        when false then "[yN]"
        else "[yn]"
        end
      end
    end
  end
end
