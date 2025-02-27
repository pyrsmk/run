module Version
  class Semver
    # @return [String]
    def initialize(version)
      match = /^(\d+)\.(\d+)\.(\d+)$/.match(version)
      raise ArgumentError.new("Invalid SEMVER number") if match.nil?

      @major = match[1].to_i
      @minor = match[2].to_i
      @patch = match[3].to_i
    end

    # @return [Integer]
    def major
      @major
    end

    # @return [Integer]
    def minor
      @minor
    end

    # @return [Integer]
    def patch
      @patch
    end

    # @return [Boolean]
    def <(semver)
      is_a_semver?(semver)

      @major < semver.major ||
      (@major == semver.major && @minor < semver.minor) ||
      (@major == semver.major && @minor == semver.minor && @patch < semver.patch)
    end

    # @return [Boolean]
    def >(semver)
      is_a_semver?(semver)

      @major > semver.major ||
      (@major == semver.major && @minor > semver.minor) ||
      (@major == semver.major && @minor == semver.minor && @patch > semver.patch)
    end

    # @return [Boolean]
    def ==(semver)
      is_a_semver?(semver)

      @major == semver.major && @minor == semver.minor && @patch == semver.patch
    end

    private

    # @return [Boolean]
    def is_a_semver?(semver)
      if !semver.respond_to?(:major) || !semver.respond_to?(:minor) || !semver.respond_to?(:patch)
        raise ArgumentError.new("SemVer compatible object expected")
      end
    end
  end
end
