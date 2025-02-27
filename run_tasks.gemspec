Gem::Specification.new do |s|
  s.name        = "run_tasks"
  s.version     = "2.0.6"
  s.files       = Dir["src/**/*.rb"]
  s.summary     = "Easy project management for the masses"
  s.authors     = ["Aurélien Delogu"]
  s.email       = "aurelien.delogu@gmail.com"
  s.homepage    = "https://github.com/pyrsmk/run"
  s.license     = "MIT"
  s.executables << "run"
  s.add_dependency "tty-prompt", "~> 0.23.1"
end
