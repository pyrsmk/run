module Run
  module Core
    module ReloadRun
      # @return [void]
      def self.run
        Run::Task::SystemTask.new("run #{$*}").run
        exit
      end
    end
  end
end
