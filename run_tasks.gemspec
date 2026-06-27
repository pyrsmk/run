Gem::Specification.new do |s|
  s.name            = "run_tasks"
  s.version         = "3.2.7"
  s.files           = Dir["src/**/*.rb"] + Dir["completions/*"] + Dir["CHEATSHEET.md"]
  s.summary         = "Task runner for the masses"
  s.authors         = ["Aurélien Delogu"]
  s.email           = "aurelien.delogu@gmail.com"
  s.homepage        = "https://github.com/pyrsmk/run"
  s.license         = "MIT"
  s.executables     = ["run"]
  s.add_dependency  "tty-prompt", "~> 0.23.1"
  s.add_dependency  "rb_monkey", "~> 0.1.0"
  s.add_dependency  "rb_gemspec", "~> 0.2.1"
  s.add_dependency  "rb_markdown", "~> 0.2.0"
end
