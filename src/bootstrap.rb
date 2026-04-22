# frozen_string_literal: true

require "digest"
require "fileutils"
require "io/console"
require "readline"
require "rubygems"
require "securerandom"
require "rb_monkey"
require "rb_gemspec"
require "rb_markdown"

# Require all files.
Dir.glob(
  File.join(__dir__, "run", "**", "*.rb"),
  &method(:require)
)

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

define_method :version do |version|
  Run::Core.runfile_version = version
end

# Run Rspec tests (if any).
task :rspec do |path = "spec/src"|
  command = "bundle exec rspec"

  if !path
    run command
  elsif path.include?(":")
    run "#{command} #{path}"
  else
    run "#{command} #{expand(File.directory?(path) ? "#{path}/**/*" : path)}"
  end
end

# Install ZSH completions.
task :install_completions do
  source = File.expand_path(File.join(__dir__, '..', 'completions', '_run'))
  dir    = File.expand_path('~/.zfunc')
  dest   = File.join(dir, '_run')
  zshrc  = File.expand_path('~/.zshrc')

  FileUtils.mkdir_p(dir)
  FileUtils.cp(source, dest)

  content = File.exist?(zshrc) ? File.read(zshrc) : ''
  additions = []
  additions << 'fpath=(~/.zfunc $fpath)' unless content.include?('~/.zfunc')
  additions << 'autoload -Uz compinit && compinit' unless content.match?(/compinit/)

  if additions.any?
    File.open(zshrc, 'a') { |f| f.puts "\n# run completions\n#{additions.join("\n")}" }
  end

  puts "ZSH completions installed. Run 'source ~/.zshrc' to activate."
end

# Publish the gem (if publishable).
task :publish do
  gemspec_files = Dir.glob(File.join(Dir.pwd, "*.gemspec"))
  raise ".gemspec file not found in the project directory" if gemspec_files.empty?
  gemspec = Gem::Specification::load(gemspec_files.first)
  run "gem build #{gemspec.name}"
  run "gem push #{gemspec.name}-#{gemspec.version}.gem"
  `rm #{gemspec.name}-#{gemspec.version}.gem`
end

# Expose helpers.
Dir.glob(File.join(__dir__, "run", "helper", "*.rb")) do |path|
  filename = File.basename(path, ".rb")
  classname = filename.split('_').map(&:capitalize).join
  helper = Object.const_get("Run::Helper::#{classname}")
  name = filename.slice(0, filename.size - 7)
  define_method(name) do |*args, **options, &block|
    if options.size == 0
      helper.new(*args).run(&block)
    else
      helper.new(*args, **options).run(&block)
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
rescue Run::Error::NonExistingRunfile => error
  puts error.message.red
  exit 7
rescue Run::Error::Aborted => error
  exit 9
rescue Run::Error::ExistingTask => error
  puts error.message.red
  exit 10
rescue Run::Error::NonExistingTask => error
  puts error.message.red
  exit 12
rescue Run::Error::RunfileVersionMismatch => error
  puts error.message.red
  exit 13
rescue => error
  format_error error
  exit 4
end
