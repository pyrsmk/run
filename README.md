# Run

Manage your Ruby projects with a straightforward syntax.

## Compatibility

Run is known to work with Ruby >=2.4.

## TODO

- add default value support in `question` helper

## Installation

```sh
gem install "run_tasks"
```

To enable ZSH completions:

```sh
run install_completions
```

## Running Run

```sh
run your_task
```

If you want to display the available tasks:

```sh
run help
```

> The help provides Run's version, so `run version` will display the same screen.

> Note that the command `run` displays the help screen by default when no task is specified.

## Writing tasks

```rb
# Displays hello.
task :hello do
  puts "hello!"
end
```

The comment is used by the Run to display the help. It must be placed directly above the task and can be multiline.

> Note that help verbatims support Markdown syntax.

`task` also support aliases, so you can call a task with different names:

```rb
task [:console, :c] do
  run "bundle exec rails c"
end
```

Running `run c` or `run console` will then start the Rails console.

## Running shell commands

```rb
# Accessing a non-existent file.
task :boom do
  run "stat foo"
  run "echo 'hello!'"
end
```

It outputs:

```sh
$ run boom

> stat foo

stat: cannot stat 'foo': No such file or directory
```

> As you can see, `run` captures errors and stops when something bad happens.

## Calling other tasks

You can run tasks arbitrarily from any other task by passing a symbol:

```rb
task :eslint do
  run "npx eslint"
end

task :flow do
  run "npx flow"
end

task :lint_js do
  run :eslint
  run :flow
end
```

By running `run lint_js` you will call `eslint` and `flow` tasks.

## Passing arguments

You can pass arguments to tasks from the CLI:

```rb
task :hello do |name, age|
  puts "Hello #{name}, you are #{age}."
end
```

```sh
$ run hello 'John Doe' 30
Hello John Doe, you are 30.
```

But also from the Runfile itself:

```rb
task :test do
  run :hello, "John Doe", 30
end
```

Tasks also support named arguments, but those ones are (currently) only available from inside the Runfile:

```rb
task :hello do |name:, age:|
  puts "Hello #{name}, you are #{age}."
end

task :test do
  run :hello, name: "John Doe", age: 30
end
```

Every parameter passed from the CLI is auto-converted:

- a float/integer is converted to a float
- true/false strings are converted to booleans
- every other parameter is converted to a symbol

We also support named booleans. For example, imagine you want to run your server in tunnel mode:

```rb
task :server do |tunnel: false|
  run "my_server #{tunnel ? "--tunnel" : ""}"
end
```

When you call...

```sh
run server +tunnel
```

...the parameter `tunnel: true` will be passed to your task. The same if you pass `-tunnel`, it will pass `false`.

## Quiet mode

If you want to run a task (or a command) without it to being able to write on STDOUT/STDERR, pass the quiet flag to true :

```rb
task :echo do
  run "echo 'test'", quiet: true
end
```

It's useful, for example, when you want to delete a file at the beginning of a task without it to being verbose when the file does not exist.

## Colorization & styles

It is often needed to colorize/stylize the messages sent to the user with `puts`. For this matter, Run is natively shipped with basic styles.

For example:

```rb
puts "Please wait...".yellow.bold
```

The available styles are :

- bold
- dim
- italic
- underline
- inverse
- strikethrough

And the available colors are :

- black
- red
- green
- yellow
- blue
- magenta
- cyan
- white
- bright_black
- bright_red
- bright_green
- bright_yellow
- bright_blue
- bright_magenta
- bright_cyan
- bright_white

## Helpers

Run comes with a few helpers to help writing tasks quicker.

### are_you_sure

When called, it asks a question to the user which has the choice to enter `y`, `yes`, `n` or `no` (the default answer). When `no` is selected, the task will exit with a `9` code.

```rb
task :dangerous_task do
  are_you_sure "This task will delete your hard drive. Are you sure about that?"
  # Some dangerous actions.
end
```

### bind

`bind` lets you group several tasks/processes so when one stops all the other will stop as well.

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

Alternatively, if you have a command that stays open until you hit `CTRL+C` (like a Docker container) and you need to catch the binding, you probably want to use `catch_interruption` instead so it lets the command handle the interruption gracefully and executes some actions afterwards.

```rb
# Run server in development mode.
task :server do
  catch_interruption("docker run -d -p 8080:80 web_server") do
    # Run some clean up actions here after the command has been interrupted.
  end
end
```

### exists

Handy helper to verify if a program exists.

```rb
task :man do
  command = exists("bat") ? "bat" : "cat"
  run "#{command} #{__dir__}/README.md"
end
```

### expand

This one takes a glob string and process it to return a list of files.

```rb
task :scan do |glob|
  expand(glob).each do |file_path|
    # Do something.
  end
end
```

### menu

It displays an advanced menu where you can choose an element that will be returned by the function.

```rb
# Array syntax
task :deploy_aws do
  region = menu "Location?", ["us‑east‑2", "us-west-1", "eu-west-1"]
end
```

```rb
# Hash syntax
task :deploy_aws do
  region = menu "Location?", {
    "US East (Ohio)" => "us‑east‑2",
    "US West (N. California)" => "us-west-1",
    "Europe (Ireland)" => "eu-west-1",
  }
end
```

### pause

You can pause a task if needed, waiting for the user to press any key.

```rb
task :deploy do
  puts "Press enter to continue.".yellow
  pause
  run :deploy_production
end
```

### question

Displays a question and returns the answer.

```rb
task :survey do
  comment = question "Did your meal was good?"
end
```

You can also pass a regex to validation the entered value:

```rb
task :age do
  age = question "What is your age?", /^\d+$/
end
```

### wait_for_interruption

If you need to wait for the user to interrupt a task of, for example, several running servers, you can use the `wait_for_interruption` helper.

```rb
# Run server in development mode.
task :server do
  Thread.new do
    # Run first server.
  end
  Thread.new do
    # Run second server.
  end
  # Wait for CTRL+C.
  wait_for_interruption do
    # Some actions to handle before terminating the task, like killing the servers.
  end
end
```

## Base tasks

Run also comes with some generic tasks for recurring tasks.

### publish

You can publish your library with:

```sh
run publish
```

> At the moment, this is only compatible with gems.

### man

It simply displays a cheatsheet for Run.

```sh
run man
```

### rspec

You can call directly `run rspec` or abstract the task like this:

```rb
# Run the tests.
task [:specs, :s, :tests, :t] do |path = "spec/src"|
  run :rspec, path
end
```

> The `rspec` task will look into `spec/src` by default, so the above task is just explanatory is you want overload default behaviour.

## Advanced usage

### Specifying Runfile path

If you want to load Run from another directory, you have two choices :

- change the working directory in your script,
- or pass the Runfile path with `RUNFILE=/path/to/Runfile.rb run my_task`

### Exit codes

Run has specific exit codes so you can handle it better in some environments, like in CI or in deployments:

- 1: Run has exited abnormally.
- 2: The required task does not exist.
- 3: Unhandled Interrupt error coming from a failed shell command.
- 4: An error has been raised in the Runfile.
- 5: The Runfile contains a syntax error.
- 6: Some parameters are invalid.
- 7: Runfile not found.
- 8: Unable to load a remote file.
- 9: The user has answered "No" to an "Are you sure?" question.
- 10: The required task already exists.
- 11: The required command is not running.
- 12: The required task does not exist.

## Development

For test purposes, it's often needed to install Run from a development branch. For this, you'll need to follow these steps:

```sh
gem install specific_install
gem specific_install http://github.com/pyrsmk/run.git <branch>
```

Do not forget to uninstall other `run_tasks` packages if needed, to avoid conflicts. And if you're under Rbenv, you'll probably need to do `rbenv rehash` too.
