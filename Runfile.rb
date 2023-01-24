require "rubygems"

SOURCE_FILE = "#{__dir__}/src/run.rb"

task :publish do
  name = Gem::Specification::load("#{__dir__}/../run.gemspec").name
  version = Gem::Specification::load("#{__dir__}/../run.gemspec").version
  shell "gem push #{name}-#{version}.gem"
end

task :specs do
  shell "bundle exec rspec specs"
end
