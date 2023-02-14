require "rubygems"

GEMSPEC_FILE_PATH = "#{__dir__}/../run_tasks.gemspec"

task :publish do
  gemspec = Gem::Specification::load(GEMSPEC_FILE_PATH)
  shell "gem build #{gemspec.name}"
  shell "gem push #{gemspec.name}-#{gemspec.version}.gem"
  `rm #{gemspec.name}-#{gemspec.version}.gem`
end

task :specs do
  shell "bundle exec rspec specs"
end
