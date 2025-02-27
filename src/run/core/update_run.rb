module Run
  module Core
    module UpdateRun
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
          Run::Task::SystemTask.new("gem update run-tasks").run
          Run::Core::ReloadRun.run
        end
      rescue Version::UnreachableError
      end
    end
  end
end
