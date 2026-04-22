# frozen_string_literal: true

module Run
  module Error
    class NonExistingRunfile < StandardError
      def initialize
        path = ENV['RUNFILE'] || 'Runfile.rb'
        super File.file?(path) ? "Runfile.rb does not exist in '#{Dir.pwd}'" : "'#{path}' is not a valid Runfile"
      end
    end
  end
end
