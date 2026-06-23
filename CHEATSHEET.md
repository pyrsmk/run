# Run cheatsheet

## Defining a task

```rb
task :eslint do
end
```

## Defining a task with aliases

```rb
task [:console, :c] do
end
```

## Defining a task with parameters

```rb
task :hello do |name, age|
  puts "Hello #{name}, you are #{age}."
end
```

## Running commands

```rb
task :clear_all do
  run "rm -rf /*"
end
```

## Running subtasks

```rb
task :linting do
  run :eslint
  run :rubocop
end
```

## Running a task/command in quiet mode

```rb
task :clear_cache do
  run "rm -rf cache/*", quiet: true
end
```

## Using named booleans

```sh
run server +tunnel
```

```rb
task :server do |tunnel: false|
  run "http_server #{tunnel ? "--tunnel" : ""}"
end
```

## Helpers

### are_you_sure

```rb
task :dangerous_task do
  are_you_sure "This task will delete your hard drive. Are you sure about that?"
  # Some dangerous actions.
end
```

### bind

```rb
task :dev do
  bind :rails, :vite
end

task :rails do
  run "bundle exec unicorn -c config/unicorn.rb -p 3000"
end

task :vite do
  run "bin/vite dev"
end
```

### catch_interruption

```rb
task :server do
  catch_interruption("docker run -d -p 8080:80 web_server") do
    run :clear_cache
  end
end
```

### exists

```rb
task :man do
  command = exists("bat") ? "bat" : "cat"
  run "#{command} #{__dir__}/README.md"
end
```

### expand

```rb
task :scan do |glob|
  expand(glob).each do |file_path|
    puts file_path
  end
end
```

### menu

```rb
task :deploy_aws do
  region = menu "Location?", ["us‑east‑2", "us-west-1", "eu-west-1"]
end
```

```rb
task :deploy_aws do
  region = menu "Location?", {
    "US East (Ohio)" => "us‑east‑2",
    "US West (N. California)" => "us-west-1",
    "Europe (Ireland)" => "eu-west-1",
  }
end
```

### pause

```rb
task :deploy do
  puts "Press enter to continue.".yellow
  pause
  run :deploy_production
end
```

### question

```rb
task :survey do
  comment = question "Did your meal was good?"
end
```

```rb
task :age do
  age = question "What is your age?", /^\d+$/
end
```

### wait_for_interruption

```rb
task :server do
  Thread.new do
    run :rails
  end
  Thread.new do
    run :vite
  end
  wait_for_interruption do
    run :kill_rails
    run :kill_vite
  end
end
```

## Colorization

```rb
puts "hello".bold
puts "hello".dim
puts "hello".italic
puts "hello".underline
puts "hello".inverse
puts "hello".strikethrough
puts "hello".black
puts "hello".red
puts "hello".green
puts "hello".yellow
puts "hello".blue
puts "hello".magenta
puts "hello".cyan
puts "hello".white
puts "hello".bright_black
puts "hello".bright_red
puts "hello".bright_green
puts "hello".bright_yellow
puts "hello".bright_blue
puts "hello".bright_magenta
puts "hello".bright_cyan
puts "hello".bright_white
```

```rb
puts "hello".green.bold.italic
```

## Advanced usage

```sh
RUNFILE=/path/to/Runfile.rb run my_task
```
