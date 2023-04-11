require "rubygems"

GEMSPEC_FILE_PATH = "#{__dir__}/run_tasks.gemspec"

task :publish do
  gemspec = Gem::Specification::load(GEMSPEC_FILE_PATH)
  run "gem build #{gemspec.name}"
  run "gem push #{gemspec.name}-#{gemspec.version}.gem"
  `rm #{gemspec.name}-#{gemspec.version}.gem`
end

task :specs do |path = "specs"|
  run "bundle exec rspec #{path}"
end
