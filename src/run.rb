#!/usr/bin/ruby

require "digest"
require "fileutils"
require "open-uri"
require "readline"
require "rubygems"
require "securerandom"

##########################################################################################

require_relative "#{__dir__}/run/markdown"
require_relative "#{__dir__}/run/string"

##########################################################################################

GEMSPEC_PATH = "#{__dir__}/../run_tasks.gemspec"
GEM = if File.exist?(GEMSPEC_PATH)
        Gem::Specification::load(GEMSPEC_PATH) # Development.
      else
        Gem::Specification::find_by_name("run_tasks") rescue nil # Production.
      end
VERSION = GEM&.version
HOMEPAGE = GEM&.homepage

##########################################################################################

@tasks = Hash.new

# @param name [Symbol]
# @param help [String]
# @yield [*Array, **Hash]
def task(name, help = "", &block)
  if !name.is_a?(Symbol)
    puts
    puts "First task parameter must be a symbol".red
    exit 6
  end
  if !help.is_a?(String)
    puts
    puts "Second task parameter must be a string".red
    exit 6
  end
  @tasks.store(
    name,
    {
      :help => Markdown.new(help).to_ansi,
      :block => block
    }
  )
end

# @param task_name_or_command [Symbol, String]
# @param arguments [Array] Optional arguments sent to the task.
# @param options [Hash] Optional options sent to the task.
def run(task_name_or_command, *arguments, **options)
  if task_name_or_command.is_a?(Symbol)
    @tasks[task_name_or_command][:block].call *arguments, **options
    return
  end

  puts ">".bright_blue + " #{task_name_or_command}".bright_white
  puts
  case system(task_name_or_command)
  when false
    puts
    puts "The command has exited with return code: #{$?.exitstatus}.".magenta
    puts
    raise Interrupt.new
  when nil
    puts
    puts "The command has failed.".magenta
    puts
    raise Interrupt.new
  end
  puts
end

# @param uri [String]
def require_remote(uri)
  cache_path = "/tmp/run_cache_#{Digest::MD5.hexdigest(uri)}"
  if !File.exists? cache_path
    File.write(cache_path, URI.parse(uri).open.read)
  end
  eval File.read(cache_path)
rescue => error
  puts
  puts "Unable to load #{uri}:".red
  puts "#{error.class}: #{error.message}".red
  exit 8
end

# @param name [String]
def require_extension(name)
  require_remote "https://pyrsmk.fra1.cdn.digitaloceanspaces.com" \
                 "/run_extensions/#{name}.rb"
end

##########################################################################################

RUNFILE = "Runfile.rb"

if !File.exists?(RUNFILE)
  puts
  puts "#{RUNFILE} does not exist".red
  exit 7
end

begin
  require "./#{RUNFILE}"
rescue SyntaxError => error
  puts
  puts "The Runfile contains a syntax error:".red
  puts error.message.red
  exit 5
end

##########################################################################################

# Show the help screen if there is no provided task, or if it's explicitly requested.
if ARGV.size == 0 || (ARGV.size == 1 && ARGV[0] == "help")
  puts
  if VERSION
    puts " Run v#{VERSION}".bright_blue
  else
    puts " Run".bright_blue
  end
  puts
  # Compute the max task names size.
  max_size = @tasks.keys.reduce(0) do |max, name|
    next max if name.size <= max
    name.size
  end
  # Display each task and their help.
  @tasks.sort.to_h.each do |name, task|
    puts " #{name}".yellow + (" " * (max_size - name.size + 4)) + task[:help]
  end
  exit
end

# Verify the latest release version.
if VERSION && HOMEPAGE
  Thread.new do
    begin
      contents = URI.parse("#{HOMEPAGE}/master/run.gemspec")
                    .open
                    .read
      version = /^\s*s.version\s*=\s*"(.+?)"\s*$/.match(contents)
      if !version.nil?
        next if File.exists?("/tmp/run_dismiss_#{version}")
        current = VERSION.split "."
        latest = version[1].split "."
        if current[0].to_i < latest[0].to_i ||
          current[1].to_i < latest[1].to_i ||
          current[2].to_i < latest[2].to_i
          puts "New ".cyan + version[1].yellow + " version released!".cyan
          puts
          puts "You can upgrade with:".cyan + "gem update run_tasks".yellow
          puts
          File.write "/tmp/run_dismiss_#{version}", ""
        end
      end
    rescue
    end
  end
end

# Run the requested task.
name = ARGV[0].gsub('-', '_').to_sym # Auto-fix hyphens to underscores.
if !@tasks.include?(name)
  puts
  puts "Unknown '#{name}' task".red
  exit 2
end
begin
  run(name, *ARGV.slice(Range.new(1, ARGV.size - 1)))
rescue Interrupt
  exit 3
rescue => error
  puts
  puts "· #{error.message}".red
  puts "· #{error.backtrace.first}".red
  exit 4
end
