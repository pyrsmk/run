# frozen_string_literal: true

module Run
  module Helper
    class ExistsHelper
      # @param program [String]
      def initialize(program)
        raise ArgumentError.new("'program' must be a String") unless program.is_a?(String)

        @program = program
      end

      # @return [Boolean]
      def run
        system("which", @program, out: File::NULL, err: File::NULL)
      end
    end
  end
end
