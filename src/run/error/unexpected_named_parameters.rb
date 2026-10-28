# frozen_string_literal: true

module Run
  module Error
    class UnexpectedNamedParameters < StandardError
      # @param task_name [Symbol]
      # @param names [Array<Symbol>]
      def initialize(task_name, names)
        super "Task '#{task_name}' does not accept named parameters: #{names.join(", ")}"
      end
    end
  end
end
