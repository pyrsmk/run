require "tty-prompt"

module Run
  module Helper
    class MenuHelper
      # @param text [String]
      # @param choices [Array | Hash]
      def initialize(text, choices)
        raise ArgumentError.new("'text' must be a String") if !text.is_a?(String)

        @text = text
        @choices = format_choices(choices)
      end

      # @return [any]
      def run
        TTY::Prompt.new.select(@text.bright_yellow, show_help: "never") do |menu|
          @choices.each do |(label, value)|
            menu.choice(name: label, value: value)
          end
        end
      end

      private

      # @param choices [Array, Hash]
      # @return [Hash]
      def format_choices(choices)
        if !choices.is_a?(Array) && !choices.is_a?(Hash)
          raise ArgumentError.new("'choices' must be an Array or an Hash")
        end

        if choices.is_a?(Array)
          return choices.each_with_object({}) do |value, hash|
            hash[value] = value
          end
        end

        choices
      end
    end
  end
end
