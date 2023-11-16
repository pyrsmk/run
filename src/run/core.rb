module Run
  module Core
    RUNFILE = "Runfile.rb"
    @@tasks = []

    # @return [void]
    def self.display_help_if_needed
      # Show the help screen if there is no provided task, or if it's explicitly requested.
      if ARGV.size == 0 || (ARGV.size == 1 && ARGV[0] == "help")
        puts
        puts " Run v#{Run::Gemspec.metadata.version}".bright_blue
        puts
        # Compute the max task names size.
        max_size = @@tasks.map do |item|
                            item[:names].join(", ")
                          end
                          .reduce(0) do |max, name|
                            next max if name.size <= max
                            name.size
                          end
        # Display each task and their help.
        @@tasks.map do |item|
                 item[:names] = item[:names].join(", ")
                 item
               end
               .sort{ |a, b| a[:names] <=> b[:names] }
               .each do |task|
                 if !task[:help]
                   puts " #{task[:name]}".yellow
                   next
                 end
                 puts task[:help].render(max_size: max_size)
               end
        exit
      end
      nil
    end

    # @param task_name_or_command [Symbol, String]
    # @param arguments [Array] Optional arguments sent to the task.
    # @param options [Hash] Optional options sent to the task.
    # @return [void]
    def self.run(task_name_or_command, *arguments, **options)
      if task_name_or_command.is_a?(Symbol)
        run_task(task_name_or_command, *arguments, **options)
        return
      end

      puts ">".bright_blue + " #{task_name_or_command}".bright_white
      puts
      case system(task_name_or_command)
      when false
        puts "The command has exited with return code: #{$?.exitstatus}.".magenta
        puts
        raise Interrupt.new
      when nil
        puts "The command has failed.".magenta
        puts
        raise Interrupt.new
      end
      puts
      nil
    end

    # @return [void]
    def self.run_requested_task
      name = ARGV[0].gsub('-', '_').to_sym # Auto-fix hyphens to underscores.
      raise Run::Error::UnknownTask.new(name) if !task_exist?(name)
      run name, *ARGV.slice(Range.new(1, ARGV.size - 1))
      nil
    end

    # @return [void]
    def self.run_run
      raise Run::Error::NonExistentRunfile.new if !File.exists?(RUNFILE)
      require "./#{RUNFILE}"
      display_help_if_needed
      run_requested_task
      nil
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
        raise Run::Error::ExistentTask.new(name) if task_exist?(name)
      end
      @@tasks << {
        names: names,
        task: Run::Task.new(&block),
        help: Run::HelpVerbatim.new(names.join(", ")),
      }
      nil
    end

    private

    # @param name [Symbol]
    # @param args [Array]
    # @param options [Hash]
    # @return [void]
    def self.run_task(name, args, options = {})
      @@tasks.find{ |item| item[:names].include? name }[:task].run(args, options)
      nil
    end

    # @param name [Symbol]
    # @return [Boolean]
    def self.task_exist?(name)
      !!@@tasks.find_index{ |item| item[:names].include? name }
    end
  end
end
