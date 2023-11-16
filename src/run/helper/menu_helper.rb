require_relative "./abstract_helper"

module Run
  module Helper
    class MenuHelper < AbstractHelper
      def initialize
      end

      # @return [String]
      def name
        "menu"
      end

      # @param text [String]
      # @param choices [Array | Hash]
      # @return [String] the chosen value
      def run(*args)
        text, choices = args

        if !text.is_a?(String)
          raise ArgumentError.new("'text' must be a String")
        end

        labels = nil
        values = nil
        choice = nil

        if choices.is_a?(Array)
          labels = choices
          values = choices
        elsif choices.is_a?(Hash)
          labels = choices.keys
          values = choices.values
        else
          raise ArgumentError.new("'choices' must be an Array or an Hash")
        end

        loop do
          labels.each_with_index do |label, index|
            puts "#{index + 1}. #{label}"
          end
          puts text
          choice = STDIN.gets.chomp.to_i
          break if !values[choice - 1].nil?
        end
        puts

        values[choice - 1]
      end
    end
  end
end
