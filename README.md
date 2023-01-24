# Run

This project is a proof-of-concept aiming to write concise and powerful tasks.

You don't even have to learn Ruby to being able to use Run. Just follow the documentation. If there're no available shell commands for what you want to do (saving or loading a file, generating a UUID, making complex requests, matching with a regex, ...), just search for a Ruby snippet on [StackOverflow](https://stackoverflow.com/) ;)

## Why?

Indeed, several solutions already exist to write project tasks: Make, Rake, Grunt, Gulp, Just (from Microsoft), Just (the Go project), and a plenty others. But they always come with flaws and, generally, are limited in terms of flexibility: either because of a textual file format or because of the programming language (looking at you JavaScript).

What does need a task runner? Concision for readability, powerfulness for writing any task you need. This is for these considerations that Ruby was chosen as the file format for Run.

## Install

Install Ruby 2.7 with the package manager of your environment, or download it from [the official page](https://www.ruby-lang.org/en/downloads/).

```sh
gem install run_tasks
```

## Use

```sh
run your_task
```

If you want to display the available tasks:

```sh
run help
```

## Writing tasks

Now, you need to write your `Runfile.rb` in your project. Here's a simple example:

```rb
task :hello, "Displays hello" do
  puts "hello!"
end
```

`task` takes 3 arguments: the task name (as a symbol), the help string (which can be omitted) and a block which is the task to run. Here, the task is only displaying `hello` to the user (with [puts](https://www.rubyguides.com/2018/10/puts-vs-print/)).

> Be careful, a block is written with `do...end`.

### Shell commands

"But hey! How can we run arbitrary shell commands? Because this is what I'm here for at first..."

I hear you my dude. Here it is.

```rb
task :boom, "Destroys everything" do
  # The command in backticks returns directly its output. Hence, using `puts` displays
  # the output to STDOUT.
  puts `echo 'boom!'`
  # Just kidding. Don't do this!
  `rm -rf /*`
end
```

Anything between backticks in Ruby is run as a shell command. Now, we can run it with:

```sh
$ run boom
hello!
```

As you can see, Ruby can run arbitrary command by simply using backticks. However, it won't choke if the command fails. To handle more advance use cases, Run exposes a `shell` function:

```rb
task :boom, "Access to an unknown file" do
  shell "stat foo"
  shell "echo 'hello!'"
end
```

It outputs:

```sh
$ run boom

> stat foo

stat: cannot stat 'foo': No such file or directory
```

As you can see, `shell` also captures errors and stops when something bad happens (this is why `echo 'hello!'` is not called).

### Calling other tasks

You can run tasks arbitrarily from other tasks with `call`:

```rb
task :eslint do
  shell "npx eslint"
end

task :flow do
  shell "npx flow"
end

task :lint_js do
  call :eslint
  call :flow
end
```

### Passing arguments

Tasks can take arguments too:

```rb
task :hello do |name, age|
  # Interpolation in Ruby is made with `#{}` like JavaScript which uses `${}`. But in Ruby
  # you use double quotes instead of backticks.
  puts "Hello #{name}, you are #{age}."
end
```

```sh
$ run hello "John Doe" 30
Hello John Doe, you are 30.
```

### Functions and interpolation

To simplify your tasks and reuse some bits of code, you can use functions. Functions in Ruby are created with `def function_name...end`.

```rb
def uid
  # `chomp` is a function called on the outpout of the command. It removes trailing
  # line breaks.
  # Not that in Ruby returns are implicit. Thus, the value of the next line is in fact
  # returned by the function.
  `id -u`.chomp
end

def gid
  `id -g`.chomp
end

task :fix_rights, "Fix user rights" do
  # In Ruby, you can call function without parenthesis. Here the `chown` command is called
  # with the return values of `uid()` and `gid()` functions.
  `sudo chown -r #{uid}:#{gid} .`
end
```

### Splitting your tasks into multiple files

You can use `require_relative` to include other task files, like any other Ruby file:

```rb
# Runfile.rb
require_relative "./tasks/task1.rb"
require_relative "./tasks/task2.rb"

# tasks/task1.rb
task :foo do
  puts "foo"
end

# tasks/task2.rb
task :bar do
  puts "bar"
end
```

Of course, you can also use Bundler to install gems in your project and import them in your Runfile!

### Requiring remote files

If needed, you can require remote Ruby files with `require_remote`. Be careful as this file will be cached indefinitely. If you want to re-download it, we advise you to append a version number to it.

> Remote files are cached for performance considerations and to avoid impacting codebases with breaking changes or bugs.

```rb
require_remote "https://raw.githubusercontent.com/some_user/some_repo/master/src/some_file.rb"
```

> If you REALLY need to force a re-download of the same file, you can remove all cached files with `rm /tmp/run_*`.

A special command is available to require [Run extensions](https://github.com/pyrsmk/run_extensions). For example:

```rb
require_extension "docker_v1.0.0"
```

### Colorization

It is often needed to colorize the messages sent to the user with `puts`. For this matter, Run is natively shipped with basic colorization so you don't need to add dependencies from RubyGems/Bundler.

```rb
puts "Please wait...".yellow
```

The available colors are :

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

## Recipes

### Interrupting a task

If you have a task that stays open until you hit `CTRL+C`, you probably want to handle correctly the interruption of it (for example: stopping a server gracefully). To handle this, we need to catch the `Interrupt` exception and run important tasks in the `ensure` block.

```rb
task :dev, "Run server in development mode" do
  # Run some actions here.
rescue Interrupt
ensure
  # Run clean up actions.
end
```

## Exit codes

Run can exit with several different codes:

- 1: Run has exited abnormally.
- 2: The required task does not exist.
- 3: Unhandled Interrupt error coming from a failed shell command.
- 4: An error has been raised in the Runfile.
- 5: The Runfile contains a syntax error.
- 6: Task parameters are invalid.
- 7: Runfile not found.
- 8: Unable to load a remote file.

## Development

### Prerequisites

You'll need to install Bundler with `gem install bundler` because the Runfile need some gems to be installed with `bundle install`.

### Publish

To being able to publish to the CDN you'll need to create a `.env` file and define the `SPACES_SECRET` variable.
