require "rubygems"

GEMSPEC_FILE_PATH = "#{__dir__}/run_tasks.gemspec"

# Publish the gem.
task :publish do
  gemspec = Gem::Specification::load(GEMSPEC_FILE_PATH)
  run "gem build #{gemspec.name}"
  run "gem push #{gemspec.name}-#{gemspec.version}.gem"
  `rm #{gemspec.name}-#{gemspec.version}.gem`
end

# Run the tests.
task [:specs, :tests] do |dir = "spec/src"|
  run :rspec, dir
end
