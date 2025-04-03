module Run
  module Error
    class NonExistingTask < StandardError
      # @param name [String]
      def initialize(name)
        super "'#{name}' does not exist"
      end
    end
  end
end
