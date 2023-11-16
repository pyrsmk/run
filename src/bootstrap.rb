require "digest"
require "fileutils"
require "io/console"
require "readline"
require "rubygems"
require "securerandom"

# Require all files.
Dir.glob(
  File.join(__dir__, "{utils,monkey,markdown,semver,run}", "**", "*.rb"),
  &method(:require)
)

# Check for new versions.
Run::Update.run

# Expose global methods.
[:task, :run].each do |name|
  define_method name do |*args, **options, &block|
    if options.size == 0
      Run::Core.send(name, *args, &block)
    else
      Run::Core.send(name, *args, **options, &block)
    end
  end
end
Dir.glob(File.join(__dir__, "run", "helper", "*.rb")) do |path|
  filename = File.basename(path, ".rb")
  next if filename == "abstract_helper"
  classname = filename.split('_').map(&:capitalize).join
  helper = classname.constantize.new
  define_method(helper.name) do |*args, **options, &block|
    if options.size == 0
      helper.run(*args, &block)
    else
      helper.run(*args, **options, &block)
    end
  end
end

# @param error [StandardError]
# @return [void]
def format_error(error)
  puts "· #{error.message}".red
  puts "· #{error.backtrace[0]}".red
  puts "· #{error.backtrace[1]}".red
  puts "· #{error.backtrace[2]}".red
  nil
end

# Run Run.
begin
  Run::Core.run_run
rescue Run::Error::UnknownTask => error
  puts error.message.red
  exit 2
rescue Interrupt
  exit 3
rescue SyntaxError => error
  format_error error
  exit 5
rescue ArgumentError => error
  format_error error
  exit 6
rescue Run::Error::NonExistentRunfile
  puts "Runfile.rb does not exist in '#{Dir.pwd}'".red
  exit 7
rescue Run::Error::Aborted => error
  exit 9
rescue Run::Error::ExistentTask => error
  puts error.message.red
  exit 10
rescue => error
  format_error error
  exit 4
end
