require "open-uri"

module Run
  module Version
    class RemoteVersion
      include SemVer::Interface

      REMOTE_GEMSPEC_URL = "https://raw.githubusercontent.com/pyrsmk/run/master/run_tasks.gemspec"

      def initialize
        contents = URI.parse(REMOTE_GEMSPEC_URL)
                      .open
                      .read
        version = /^\s*s.version\s*=\s*"(.+?)"\s*$/.match(contents)
        raise RemoteVersionUnreachable.new if version.nil?

        @origin = SemVer::Version.new(Run::Gemspec.metadata.version.to_s)
      rescue SocketError
        raise RemoteVersionUnreachable.new
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
