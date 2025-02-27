module Gemspec
  class Metadata
    # @param lib_name [String]
    def initialize(lib_name)
      @lib_name = lib_name
    end

    # @return [Hash]
    def read
      @_read ||= (
        path = "#{__dir__}/../../#{@lib_name}.gemspec"

        # Development.
        if File.exist?(path)
          Gem::Specification::load(path)
        # Production.
        else
          Gem::Specification::find_by_name(@lib_name) rescue nil
        end
      )
    end
  end
end
