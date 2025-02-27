module Run
  module Core
    RUNFILE_FILENAME = "Runfile.rb"
    RESERVED_TASK_NAMES = ["help", "version"]
    @@tasks = []

    # @return [void]
    def self.run_run
      raise Run::Error::NonExistingRunfile.new if !File.exists?(RUNFILE_FILENAME)
      require "./#{RUNFILE_FILENAME}"
      run_requested_task if !display_help_if_needed
    end

    # @param task_name_or_command [Symbol, String]
    # @param arguments [Array] Optional arguments sent to the task.
    # @param options [Hash] Optional options sent to the task.
    # @return [void]
    def self.run(task_name_or_command, *arguments, **options)
      if task_name_or_command.is_a?(Symbol)
        run_block_task(task_name_or_command, *arguments, **options)
      else
        run_system_task(task_name_or_command)
      end
    end

    # @param names [Array<Symbol> | Symbol]
    # @param block [Proc]
    # @return [void]
    def self.task(names, &block)
      names = !names.is_a?(Array) ? [names] : names

      names.each do |name|
        if !name.is_a?(Symbol)
          raise ArgumentError.new("'name' must be a Symbol or an Array of Symbol")
        end
        raise Run::Error::ExistingTask.new(name) if task_exist?(name)
        raise Run::Error::ReservedTaskName.new(name) if RESERVED_TASK_NAMES.include?(name)
      end

      @@tasks << {
        names: names,
        task: Run::Task::BlockTask.new(&block),
      }
    end

    private

    # @return [Boolean]
    def self.display_help_if_needed
      if ARGV.size == 0 || (ARGV.size == 1 && ["help", "version"].include?(ARGV[0]))
        puts
        puts " Run v#{Gemspec::Metadata.new("run_tasks").read.version}".bright_blue
        puts
        Run::Core::Help.run(File.read("./#{RUNFILE_FILENAME}"))
        return true
      end
      false
    end

    # @return [void]
    def self.run_requested_task
      name = ARGV[0].gsub('-', '_').to_sym # Auto-replace hyphens to underscores.
      raise Run::Error::UnknownTask.new(name) if !task_exist?(name)

      # Cast value to the right type.
      args = ARGV.slice(1, ARGV.size - 1).map do |arg|
        value = Float(arg) rescue nil
        next value if !value.nil?
        next true if arg == "true"
        next false if arg == "false"
        next arg.to_sym if arg.match?(/^\w+$/)
        arg
      end

      run name, *args
    end

    # @param name [Symbol]
    # @return [Boolean]
    def self.task_exist?(name)
      !!@@tasks.find_index{ |item| item[:names].include? name }
    end

    # @param name [Symbol]
    # @param args [Array]
    # @param options [Hash]
    # @return [void]
    def self.run_block_task(name, *args, **options)
      @@tasks.find{ |item| item[:names].include? name }[:task].run(*args, **options)
    end

    # @param name [Symbol]
    # @return [void]
    def self.run_system_task(name)
      Run::Task::SystemTask.new(name).run
    end
  end
end
