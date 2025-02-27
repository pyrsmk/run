# Run

Manage your Ruby projects with a straightforward syntax.

## Compatibility

Run is compatible with Ruby >=2.4.

## Installation

```sh
gem install run_tasks
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
  #
  # Some dangerous actions.
  #
end
```

### pause

You can pause a task if needed, waiting for the user to press any key.

```rb
task :some_task do
  # some action
  pause
  # some action
end
```

### menu

It displays an advanced menu where you can choose an element that will be returned by the function.

```rb
# Array syntax
task :deploy_aws do
  region = menu "Where?", ["us‑east‑2", "us-west-1", "eu-west-1"]
end
```

```rb
# Hash syntax
task :deploy_aws do
  region = menu "Where?", {
    "US East (Ohio)" => "us‑east‑2",
    "US West (N. California)" => "us-west-1",
    "Europe (Ireland)" => "eu-west-1",
  }
end
```

### wait_for_interruption

If you need to wait for the user to interrupt a task of, for example, several running servers, you can use the `wait_for_interruption` helper.

```rb
# Run server in development mode.
task :dev do
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

### catch_interruption

Alternatively, if you have a command that stays open until you hit `CTRL+C` (like a Docker container) and you need to catch the binding, you probably want to use `catch_interruption` instead so it lets the command handle the interruption gracefully and executes some actions afterwards.

```rb
# Run server in development mode.
task :dev do
  catch_interruption("docker run -d -p 8080:80 my_docker_image") do
    # Run some clean up actions here after the command has been interrupted.
  end
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

## Base tasks

Run also comes with some generic tasks for recurring tasks.

### rspec

```rb
# Run the tests.
task [:specs, :s, :tests, :t] do |path = "spec/src"|
  run :rspec, path
end
```

## Exit codes

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
