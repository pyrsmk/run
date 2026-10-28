# frozen_string_literal: true

module Run
  module Error
    class DuplicateParameter < StandardError
      # @param name [Symbol]
      def initialize(name)
        super "Parameter '#{name}' is given more than once"
      end
    end
  end
end
