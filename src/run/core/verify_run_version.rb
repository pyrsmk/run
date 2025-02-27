module Run
  module Core
    module VerifyRunVersion
      REMOTE_GEMSPEC_URL = "https://raw.githubusercontent.com/pyrsmk/run/master/run_tasks.gemspec"

      # @return [void]
      def self.run
        local_version = Version::Semver.new(
          Version::LocalGemspecVersion.new(Gemspec::Metadata.new("run_tasks")).extract
        )
        remote_version = Version::Semver.new(
          Version::RemoteGemspecVersion.new(REMOTE_GEMSPEC_URL).extract
        )
        if local_version.major == remote_version.major && local_version < remote_version
          puts
          puts " A new version of Run is available: #{remote_version}".bright_yellow
          puts " Please update with: `gem update run_tasks`".bright_yellow
          puts
        end
      rescue Version::UnreachableError
      end
    end
  end
end
