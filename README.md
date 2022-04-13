# run

> Run your tasks like a gangsta! ([DDU-DU DDU-DU!!](https://www.youtube.com/watch?v=IHNzOHi8sJs))

This project is a proof-of-concept aiming to write concise and powerful tasks.

You don't even have to learn Ruby to being able to use `run`. Just follow the documentation. If there're no available shell commands for what you want to do (saving or loading a file, generating a UUID, making complex requests, matching with a regex, ...), [StackOverflow](https://stackoverflow.com/) is your friend!

Have fun!

## Notes about Ruby vs Make

Many of you will probably think "What ?! I need to install a new language on my system to use Run ? And I also need yo learn Ruby ?!". To them, I would respond "Hey ! With make it's actually the same, but 100x worse !".

## Why ?

Across the years I've used several solutions to write my project tasks: Grunt, Gulp, Just (from Microsoft), make, Just (the Go project), ... There are plenty of solutions out there but they always come with flaws (in my opinion): too much verbosity, lack of performance, limited flexibility, etc.

Last years, I primarily used Makefiles since `make` is available for all environments and the base syntax is simple. But when you need to something more complex it's a real pain to handle. I could manage to achieve what I wanted for a couple of years but I finally reached a no-no point: the impossibility to simply handle functions with return values. Variables and functions in Makefiles are, in fact, expanded and resolved only once. Then, if you want to re-resolve something you cannot use that variable/function again and must copy/paste its behavior inside your task, making your Makefile more and more poorly factorized.

I'd already thought about some solutions a few years ago but they would have taken me too much time to write. Also, I was in a project with an extremely tight deadline. I wanted to have a way to express tasks with a concise syntax and yet the ability to write more advanced things clearly (like reading, writing a file, capture output of a command, ...) and displays an help screen natively. I wanted to use directly a language instead of writing a global framework with a special file syntax, because it would be way quicker to implement. Hence, this is why I chose Ruby.

Ruby have a comprehensive and exhaustive API, with a very concise syntax and good meta-programming features. A few hours later and all my tasks were running smoothly 🎉

## Install

Install Ruby with the package manager of your environment, or download it from [the official page](https://www.ruby-lang.org/en/downloads/).

When you're done, download the source file to a directory in your `PATH`, like `~/.local/bin/`.

```sh
wget https://the-origamist.fra1.cdn.digitaloceanspaces.com/run/run_latest.rb -O ~/.local/bin/run
chmod +x ~/.local/bin/run
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
  `echo 'boom!'`
  # Just kidding. Don't do this!
  `rm -rf /*`
end
```

```sh
# Contrary to what's expected, the `boom` task won't display `boom!`.
$ run boom
```

In Ruby you can run commands with backticks but note you won't have any output displayed on screen. Also, if the command fails the other tasks will continue to run. If you need something more fancy, you can use the `shell` function:

```rb
task :hello, "Displays hello" do
  shell "echo 'hello!'"
end
```

```sh
# It outputs the result of our task's commands.
$ run hello

> echo 'hello!'

hello!
```

Let's try with a failing command:

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

### Calling other tasks

One another useful feature is to being able to run tasks arbitrarily from other tasks:

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

You can pass arguments to your tasks. Those will be accessible with:

```rb
task :echo do |arguments|
  puts arguments[0]
end
```

This task will output the first argument on STDOUT:

```sh
> run echo hello
hello
```

### Functions and interpolation

Interpolation and the use of functions makes it trivial to integrate data inside your tasks. In Ruby, interpolation is as easy and powerful as you can do in JavaScript ([read about template literals](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Template_literals)).

```rb
def uid
  `id -u`.chomp
end

def gid
  `id -g`.chomp
end

task :fix_rights, "Fix user rights" do
  `sudo chown -r #{uid}:#{gid} .`
end
```

> In Ruby, you can forgot about parens when you're calling a function.

> Ruby also have implicit returns: the last value of a function is the one returned. But you can also use `return` if you need to return something that is not the last line of your function.

> Note the `chomp` call after commands. These commands return STDOUT as a string with a trailing newline: `chomp` is used to trim them.

### Splitting your tasks into multiple files

You can use `require` to include other task files, like any other Ruby file:

```rb
# Runfile.rb
require "tasks/task1.rb"
require "tasks/task2.rb"

# tasks/task1.rb
task :foo do
  puts "foo"
end

# tasks/task2.rb
task :bar do
  puts "bar"
end
```

### Requiring remote files

If needed, you can require remote Ruby files with `require_remote`. Be careful, this file will be cached indefinitely. If you want to re-download it, we advise you to append a version number to it. This is for performance considerations and to avoid impacting codebases with an updated remote file with breaking changes or bugs.

```rb
require_remote "https://raw.githubusercontent.com/some_user/some_repo/master/src/some_file.rb"
```

> If you REALLY need to force a re-download of the same file, you can remove all cached files with `rm /tmp/run_*`.

A special command is available to require [Run extensions](https://github.com/pyrsmk/run_extensions). For example:

```rb
require_extension "docker_v1.0.0"
```

### Colorization

It is often needed to colorize your messages sent to the user with `puts`. For this matter, Run is natively shipped with basic colorization so you don't need to add dependencies from Rubygems/Bundler (no need to install a whole dev stack, thanks).

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

## Recipes

### Interrupting a task

If you have a task that stays open until you hit `CTRL+C`, you probably want to handle correctly the interruption of it (for example: stopping gracefully a server). To handle this case, we need to catch the Interrupt exception quietly and run important tasks in the `ensure` block.

```rb
task :dev, "Run server in development mode" do
  # Run some actions here.
rescue Interrupt
ensure
  # Run clean up actions.
end
```

The double `rescue` is used to avoid having an ugly stack trace printing on STDOUT if you hit `CTRL+C` multiple times.

## TODO

- publish system
- add version header and verify version against the one installed + auto-update
- auto-completion
- add proper tests
