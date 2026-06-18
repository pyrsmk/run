# frozen_string_literal: true

module Run
  module Error
    class NonExistingRunfile < StandardError
      def initialize
        path = ENV['RUNFILE'] || 'Runfile.rb'
        super File.file?(path) ?
              "'#{path}' is not a valid Runfile" :
              "Runfile.rb does not exist in '#{Dir.pwd}'"
      end
    end
  end
end
