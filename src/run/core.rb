# frozen_string_literal: true

module Run
  module Core
    RUNFILE_FILENAME = ENV.fetch('RUNFILE', 'Runfile.rb')
    RESERVED_TASK_NAMES = ["help", "version"]
    NAME_PATTERN = /[a-zA-Z_]\w*(?:-\w+)*/
    @@tasks = []
    @@runfile_version = nil

    # @param version [Integer]
    # @return [void]
    def self.runfile_version=(version)
      @@runfile_version = version.to_i
    end

    # @return [void]
    def self.run_run
      if ARGV.size == 1 && ARGV[0] == "--completions"
        require File.expand_path(RUNFILE_FILENAME) if File.exist?(RUNFILE_FILENAME)
        puts completions.join("\n")
        return
      end
      raise Run::Error::NonExistingRunfile.new if !File.file?(RUNFILE_FILENAME)
      if ARGV.size == 1 && ARGV[0] == "version"
        puts version
      elsif ARGV.size == 0 || (ARGV.size == 1 && ARGV[0] == "help")
        require File.expand_path(RUNFILE_FILENAME)
        check_runfile_version!
        display_help
      else
        require File.expand_path(RUNFILE_FILENAME)
        check_runfile_version!
        run_requested_task
      end
    end

    # @param task_name_or_command [Symbol, String]
    # @param arguments [Array] Optional arguments sent to the task.
    # @param options [Hash] Optional options sent to the task.
    # @return [void]
    def self.run(task_name_or_command, *arguments, **options)
      quiet = options.delete(:quiet) || quiet?
      with_quiet_context(quiet) do
        if task_name_or_command.is_a?(Symbol)
          run_block_task(task_name_or_command, *arguments, **options)
        else
          run_system_task(task_name_or_command)
        end
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

    # @return [void]
    def self.check_runfile_version!
      if (@@runfile_version || 2) != version.to_s.split(".").first.to_i
        raise Run::Error::RunfileVersionMismatch.new
      end
    end

    # @return [void]
    def self.display_version
      puts Gemspec::Metadata.new("run_tasks").read.version
    end

    # @return [void]
    def self.completions
      (@@tasks.flat_map{ |t| t[:names] }.map(&:to_s) + RESERVED_TASK_NAMES).sort.uniq
    end

    # @return [void]
    def self.display_help
      puts
      puts " Run v#{version}".bright_blue
      contents = Run::Core::Help.run(File.read(File.join(Dir.pwd, RUNFILE_FILENAME)))
      if contents.strip.size > 0
        puts
        puts " Project tasks:".magenta
        puts
        puts contents
      end
      puts
      puts " Global tasks:".magenta
      puts
      puts Run::Core::Help.run(File.read(File.join(__dir__, "..", "bootstrap.rb")))
      puts
    end

    # @return [void]
    def self.run_requested_task
      name = ARGV[0].gsub('-', '_').to_sym # Auto-replace hyphens to underscores.
      raise Run::Error::UnknownTask.new(name) if !task_exist?(name)

      args, options = parse_arguments(ARGV.drop(1))
      run name, *args, **options
    end

    # @param words [Array<String>]
    # @return [Array(Array, Hash)]
    def self.parse_arguments(words)
      args = []
      options = {}

      words.each do |word|
        if (match = word.match(/\A([+-])(#{NAME_PATTERN})\z/))
          add_option(options, match[2], match[1] == "+")
        elsif (match = word.match(/\A(#{NAME_PATTERN})=(.*)\z/m))
          values = match[2].split(",", -1).map { |value| convert_argument(value) }
          add_option(options, match[1], values.size > 1 ? values : convert_argument(match[2]))
        else
          args << convert_argument(word)
        end
      end

      [args, options]
    end

    # @param value [String]
    # @return [Integer, Float, Boolean, String]
    def self.convert_argument(value)
      case value
      when /\A-?(?:0|[1-9]\d*)\z/ then Integer(value, 10)
      when /\A-?(?:0|[1-9]\d*)\.\d+\z/ then Float(value)
      when "true" then true
      when "false" then false
      else value
      end
    end

    # @param options [Hash]
    # @param name [String]
    # @param value [Object]
    # @return [void]
    def self.add_option(options, name, value)
      key = name.tr("-", "_").to_sym
      raise ArgumentError.new("Parameter '#{key}' is given more than once") if options.key?(key)

      options[key] = value
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
      task = @@tasks.find{ |item| item[:names].include? name }
      raise Error::NonExistingTask.new(name) if task.nil?
      if options.any? && !task[:task].accepts_keywords?
        raise ArgumentError.new("Task '#{name}' does not accept named parameters: #{options.keys.join(", ")}")
      end

      task[:task].run(*args, **options)
    end

    # @param command [String]
    # @return [void]
    def self.run_system_task(command)
      Run::Task::SystemTask.new(command).run
    end

    # @return [String]
    def self.version
      Gemspec::Metadata.new("run_tasks").read.version
    end

    # @return [Boolean]
    def self.quiet?
      !!Thread.current[:quiet]
    end

    # @param quiet [Boolean]
    # @return [void]
    def self.with_quiet_context(quiet)
      already_quiet = quiet?
      Thread.current[:quiet] = quiet || already_quiet

      prev_stdout = nil
      prev_stderr = nil

      if quiet && !already_quiet
        prev_stdout = $stdout.dup
        prev_stderr = $stderr.dup
        $stdout.reopen(File::NULL)
        $stderr.reopen(File::NULL)
      end

      yield
    rescue Interrupt
      raise unless Thread.current[:quiet]
    ensure
      if prev_stdout
        $stdout.reopen(prev_stdout)
        $stderr.reopen(prev_stderr)
        prev_stdout.close
        prev_stderr.close
      end
      Thread.current[:quiet] = already_quiet
    end
  end
end
