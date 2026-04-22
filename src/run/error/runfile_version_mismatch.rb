# frozen_string_literal: true

module Run
  module Error
    class RunfileVersionMismatch < StandardError
      def initialize
        super "Runfile version mismatches Run version"
      end
    end
  end
end
