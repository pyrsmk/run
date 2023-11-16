module SemVer
  class Version
    include SemVerInterface

    def initialize(version)
      match = /^(\d+)\.(\d+)\.(\d+)$/.match(version)
      raise "Invalid SEMVER number" if match.nil?

      @major = match[1]
      @minor = match[2]
      @patch = match[3]
    end

    def major
      @major
    end

    def minor
      @minor
    end

    def patch
      @patch
    end

    def <(semver)
      is_a_semver?(semver)

      @major < semver.major ||
      (@major == semver.major && @minor < semver.minor) ||
      (@major == semver.major && @minor == semver.minor && @patch < semver.patch)
    end

    def >(semver)
      is_a_semver?(semver)

      @major > semver.major ||
      (@major == semver.major && @minor > semver.minor) ||
      (@major == semver.major && @minor == semver.minor && @patch > semver.patch)
    end

    def ==(semver)
      is_a_semver?(semver)

      @major == semver.major && @minor == semver.minor && @patch == semver.patch
    end

    private

    def is_a_semver?(semver)
      if !semver.is_a?(Interface)
        raise ArgumentError.new("SemVer::Interface object expected")
      end
    end
  end
end
