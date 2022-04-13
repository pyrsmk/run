#!/usr/bin/ruby

require "digest"
require "fileutils"
require "open-uri"
require "readline"
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
  puts "#{">".green} #{command}"
  puts
  if system(command) === false
    puts
    puts "The command has exited with return code: #{$?.exitstatus}.".magenta
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
  puts "Unable to load #{uri}:".red
  puts "#{error.class}: #{error.message}".red
end

def require_extension(name)
  require_remote "https://pyrsmk.fra1.cdn.digitaloceanspaces.com" \
                 "/run_extensions/#{name}.rb"
end

##########################################################################################

class String
  @@colors = {
    :black          => "30",
    :red            => "31",
    :green          => "32",
    :yellow         => "33",
    :blue           => "34",
    :magenta        => "35",
    :cyan           => "36",
    :white          => "37",
    :bright_black   => "30;1",
    :bright_red     => "31;1",
    :bright_green   => "32;1",
    :bright_yellow  => "33;1",
    :bright_blue    => "34;1",
    :bright_magenta => "35;1",
    :bright_cyan    => "36;1",
    :bright_white   => "37;1",
  }

  def colorize(color)
    "\033[#{@@colors[color.to_sym]}m#{self}\033[0m"
  end

  def black;          colorize(:black); end
  def red;            colorize(:red); end
  def green;          colorize(:green); end
  def yellow;         colorize(:yellow); end
  def blue;           colorize(:blue); end
  def magenta;        colorize(:magenta); end
  def cyan;           colorize(:cyan); end
  def white;          colorize(:white); end
  def bright_black;   colorize(:bright_black); end
  def bright_red;     colorize(:bright_red); end
  def bright_green;   colorize(:bright_green); end
  def bright_yellow;  colorize(:bright_yellow); end
  def bright_blue;    colorize(:bright_blue); end
  def bright_magenta; colorize(:bright_magenta); end
  def bright_cyan;    colorize(:bright_cyan); end
  def bright_white;   colorize(:bright_white); end
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
  puts " Run v#{VERSION}".bright_blue
  puts
  @tasks.sort.to_h.each do |name, task|
    puts " #{name}".yellow + (" " * (35 - name.size)) + task[:help]
  end
  exit
end

# Verify the latest release version.
contents = URI.parse("https://pyrsmk.fra1.cdn.digitaloceanspaces.com/run/run_latest.rb")
              .open
              .read
version = /^VERSION = "(\d\.\d\.\d)"$/.match(contents)
if !version.nil?
  current = VERSION.split "."
  latest = version[1].split "."
  if current[0].to_i < latest[0].to_i ||
     current[1].to_i < latest[1].to_i ||
     current[2].to_i < latest[2].to_i
    puts "New ".cyan + version[1].yellow + " version released!".cyan
    puts "Update with: `".cyan +
         "wget https://pyrsmk.fra1.cdn.digitaloceanspaces.com/run/".yellow +
         "run_latest.rb -O ~/.local/bin/run && chmod +x ~/.local/bin/run".yellow +
         "`".cyan
    puts
  end
end

# Run the requested tasks.
name = ARGV[0].to_sym
if !@tasks.include?(name)
  puts "Unknown '#{name}' task"
  exit 1
end
call name, ARGV.slice(1..)
