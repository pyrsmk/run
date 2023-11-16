module Run
  module Update
    # @return [void]
    def self.run
      local_version = Run::Version::LocalVersion.new
      remote_version = Run::Version::RemoteVersion.new

      if local_version < remote_version &&
        local_version.major == remote_version.major
        Run::Task.new("gem update run-tasks").run
        Run::Reload.run
      end

      nil
    rescue Run::Version::RemoteVersionUnreachable
    end
  end
end
