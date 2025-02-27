module Run
  module Error
    class ReservedTaskName < StandardError
      # @param name [String]
      def initialize(name)
        super "'#{name}' task name is reserved"
      end
    end
  end
end
