module Run
  module Version
    class LocalVersion
      include SemVer::Interface

      def initialize
        @origin = SemVer::Version.new(Run::Gemspec.metadata.version.to_s)
      end

      def major
        @origin.major
      end

      def minor
        @origin.minor
      end

      def patch
        @origin.patch
      end

      def <(semver)
        @origin < semver
      end

      def >(semver)
        @origin > semver
      end

      def ==(semver)
        @origin == semver
      end
    end
  end
end
