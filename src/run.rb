#!/usr/bin/ruby

require "digest"
require "fileutils"
require "open-uri"
require "readline"
require "rubygems"
require "securerandom"

##########################################################################################

require_relative "#{__dir__}/run/string"
require_relative "#{__dir__}/run/markdown/engine"

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

@tasks = {}

# @param name [Symbol]
# @param help [String]
# @yield [*Array, **Hash]
def task(name, help = nil, &block)
  if !name.is_a?(Symbol)
    puts
    puts "'name' parameter must be a symbol".red
    exit 6
  end
  if !help.nil?
    if !help.is_a?(String)
      puts
      puts "'help' parameter must be a string".red
      exit 6
    end
  else
    # Load comments directly above the task as help verbatim.
    caller = caller_locations[0]
    lines = File.readlines(caller.absolute_path)
    help = (0..(caller.lineno - 2)).to_a.reverse.reduce([]) do |comments, lineno|
      match = /^\s*#\s*(?<comment>.+?)\s*$/.match(lines[lineno])
      break comments if match.nil?
      comments << match[:comment]
      comments
    end.reverse
  end
  @tasks.store(
    name,
    {
      :help => help.is_a?(String) ? [help] : help,
      :block => block
    }
  )
end

# @param task_name_or_command [Symbol, String]
# @param arguments [Array] Optional arguments sent to the task.
# @param options [Hash] Optional options sent to the task.
def run(task_name_or_command, *arguments, **options)
  if task_name_or_command.is_a?(Symbol)
    if options.empty?
      @tasks[task_name_or_command][:block].call *arguments
    else
      @tasks[task_name_or_command][:block].call *arguments, **options
    end
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

def are_you_sure?(text = "Are you sure?")
  puts "#{text.yellow.bold} [yN]"
  answer = STDIN.gets.chomp.downcase.chars.first
  exit 9 unless answer == "y"
end

def menu(text, choices)
  labels = nil
  values = nil
  choice = nil

  if choices.is_a?(Array)
    labels = choices
    values = choices
  elsif choices.is_a?(Hash)
    labels = choices.keys
    values = choices.values
  else
    puts "menu() 'choices' parameter must be an Array or an Hash".red
    exit 10
  end

  loop do
    labels.each_with_index do |label, index|
      puts "#{index + 1}. #{label}"
    end
    puts text
    choice = STDIN.gets.chomp.to_i
    break if !values[choice - 1].nil?
  end
  puts

  values[choice - 1]
end

# @param uri [String]
def require_remote(uri)
  cache_path = "/tmp/run_cache_#{Digest::MD5.hexdigest(uri)}"
  if !File.exist? cache_path
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

if !File.exist?(RUNFILE)
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
    if task[:help].size == 0
      puts " #{name}".yellow
      next
    end
    task[:help].each_with_index do |help, index|
      help = Markdown::Engine.new(help).to_ansi
      if index == 0
        puts " #{name}".yellow + (" " * (max_size - name.size + 4)) + help
        next
      end
      puts (" " * (max_size + 5)) + help
    end
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
        next if File.exist?("/tmp/run_dismiss_#{version}")
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
  message = if error.message.size > 300
              "#{error.message[0, length]}..."
            else
              error.message
            end
  puts "· #{message}".red
  error.backtrace.each do |trace|
    puts "· #{trace}".red
  end
  exit 4
end
