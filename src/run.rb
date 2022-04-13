#!/usr/bin/ruby

# TODO
# - add version header and verify version against the one installed + auto-update
# - auto-completion
# - improve colorization with simple functions: "foo".yellow
# - improve require_remote with version support
# - add proper tests

require "digest"
require "fileutils"
require "open-uri"
require "securerandom"

VERSION = "1.0.0"

@tasks = Hash.new

# Define a task.
def task(name, help = "", &block)
  if !name.is_a?(Symbol)
    puts "first task parameter must be a symbol"
    exit 1
  end
  if !help.is_a?(String)
    puts "second task parameter must be a string"
    exit 1
  end
  @tasks.store(name, { :help => help, :block => block })
end

# Call a task.
def call(name, arguments)
  @tasks[name][:block].call arguments
end

# Run a shell command that will fail the tasks if it fails itself. It also add the
# ability to interect with the command, contrary to backticks syntax.
def shell(command)
  puts "#{">".colorize(:green)} #{command}"
  puts
  if system(command) === false
    puts
    puts "The command has exited with return code: #{$?.exitstatus}.".colorize(:magenta)
    puts
    raise Interrupt.new
  end
end

def require_remote(uri)
  cache_path = "/tmp/run_#{Digest::MD5.hexdigest(uri)}"
  if !File.exists? cache_path
    File.write(cache_path, URI.parse(uri).open.read)
  end
  eval File.read(cache_path)
rescue error
  puts "Unable to load #{uri}:".colorize(:red)
  puts "#{error.class}: #{error.message}".colorize(:red)
end

def require_extension(name)
  require_remote "https://the-origamist.fra1.cdn.digitaloceanspaces.com/run_extensions/#{name}.rb"
end

##########################################################################################

class String
  def colorize(color)
    colors = {
      :black   => 30,
      :red     => 31,
      :green   => 32,
      :yellow  => 33,
      :blue    => 34,
      :magenta => 35,
      :cyan    => 36,
      :white   => 37,
    }
    "\033[#{colors[color.to_sym]}m#{self}\033[0m"
  end
end

##########################################################################################

RUNFILE = "Runfile.rb"

if !File.exists?(RUNFILE)
  puts "#{RUNFILE} does not exist"
  exit 1
end

require "./#{RUNFILE}"

##########################################################################################

# Show the help screen if there is no provided task, or if it's explicitly requested.
if ARGV.size == 0 || (ARGV.size == 1 && ARGV[0] == "help")
  puts
  puts " run v#{VERSION}"
  puts
  @tasks.sort.to_h.each do |name, task|
    puts " #{name}#{" " * (35 - name.size)}#{task[:help]}"
  end
  exit
end

# Run the requested tasks.
name = ARGV[0].to_sym
if !@tasks.include?(name)
  puts "Unknown '#{name}' task"
  exit 1
end
call name, ARGV.slice(1..)
