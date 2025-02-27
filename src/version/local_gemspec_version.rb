module Version
  class LocalGemspecVersion
    # @param gemspec [Gemspec::Metadata]
    def initialize(gemspec)
      @gemspec = gemspec
    end

    # @return [String]
    def extract
      @gemspec.read.version.to_s
    end
  end
end
