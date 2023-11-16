module Run
  module Error
    class UnknownTask < StandardError
      # @param name [String]
      def initialize(name)
        super "Unknown '#{name}' task"
      end
    end
  end
end
