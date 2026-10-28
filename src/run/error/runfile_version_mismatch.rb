# frozen_string_literal: true

module Run
  module Error
    class RunfileVersionMismatch < StandardError
      # @param major [Integer, nil]
      def initialize(major = nil)
        if major
          super "Runfile declares version #{major}, which needs Run #{major}: gem install run_tasks -v '~> #{major}.0'"
        else
          super "Runfile version mismatches Run version"
        end
      end
    end
  end
end
