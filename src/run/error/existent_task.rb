module Run
  module Error
    class ExistentTask < StandardError
      # @param name [String]
      def initialize(name)
        super "'#{name}' task already exists"
      end
    end
  end
end
