module Run
  module Gemspec
    GEMSPEC_PATH = "#{__dir__}/../../run_tasks.gemspec"

    # @return [Hash]
    def self.metadata
      @@metadata ||= if File.exist?(GEMSPEC_PATH)
                       Gem::Specification::load(GEMSPEC_PATH) # Development.
                     else
                       Gem::Specification::find_by_name("run_tasks") rescue nil # Production.
                     end
    end
  end
end
