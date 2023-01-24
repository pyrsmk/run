require "open3"
require "securerandom"

RUN_PATH = "../../../bin/run"

RSpec.describe "run" do
  describe "Loading" do
    it "loads Runfiles" do
      Dir.chdir("#{__dir__}/fixtures/loading1") do
        _, _, status = Open3.capture3(RUN_PATH)
        expect(status.exitstatus).to eq 0
      end
    end

    it "fails if the Runfile does not exist" do
      Dir.chdir(__dir__) do
        _, _, status = Open3.capture3("/")
        expect(status.exitstatus).to eq 7
      end
    end

    it "fails if the Runfile contains a syntax error" do
      Dir.chdir("#{__dir__}/fixtures/loading2") do
        _, _, status = Open3.capture3(RUN_PATH)
        expect(status.exitstatus).to eq 5
      end
    end
  end

  describe "Tasks" do
    it "fails if first parameter is not a symbol" do
      Dir.chdir("#{__dir__}/fixtures/tasks1") do
        stdout, _, status = Open3.capture3(RUN_PATH)
        expect(stdout.chomp).to eq "first task parameter must be a symbol"
        expect(status.exitstatus).to eq 6
      end
    end

    it "fails if second parameter is not a string" do
      Dir.chdir("#{__dir__}/fixtures/tasks2") do
        stdout, _, status = Open3.capture3(RUN_PATH)
        expect(stdout.chomp).to eq "second task parameter must be a string"
        expect(status.exitstatus).to eq 6
      end
    end

    it "fails if the task does not exist" do
      Dir.chdir("#{__dir__}/fixtures/tasks4") do
        stdout, _, status = Open3.capture3("#{RUN_PATH} foo")
        expect(stdout).to include "Unknown"
        expect(status.exitstatus).to eq 2
      end
    end

    it "fails if the task raises an error" do
      Dir.chdir("#{__dir__}/fixtures/tasks5") do
        stdout, _, status = Open3.capture3("#{RUN_PATH} foo")
        expect(stdout).to include "bar"
        expect(status.exitstatus).to eq 4
      end
    end
  end

  describe "Help screen" do
    it "shows help screen by default" do
      Dir.chdir("#{__dir__}/fixtures/help_screen") do
        stdout, _, _ = Open3.capture3(RUN_PATH)
        expect(stdout).to include "Run"
        expect(stdout).to include "test1"
        expect(stdout).to include "test2"
      end
    end

    it "shows help screen when required" do
      Dir.chdir("#{__dir__}/fixtures/help_screen") do
        stdout, _, _ = Open3.capture3(RUN_PATH)
        expect(stdout).to include "Run"
        expect(stdout).to include "test1"
        expect(stdout).to include "test2"
      end
    end
  end

  describe "Calling tasks" do
    it "calls the required task from CLI" do
      Dir.chdir("#{__dir__}/fixtures/tasks3") do
        stdout, _, _ = Open3.capture3("#{RUN_PATH} task1")
        expect(stdout).to include "task1"
      end
    end

    it "passes arguments from CLI" do
      Dir.chdir("#{__dir__}/fixtures/tasks3") do
        stdout, _, _ = Open3.capture3("#{RUN_PATH} task2 foo bar")
        expect(stdout).to include "foo"
        expect(stdout).to include "bar"
      end
    end

    it "calls the required tasks from Runfile" do
      Dir.chdir("#{__dir__}/fixtures/tasks3") do
        stdout, _, _ = Open3.capture3("#{RUN_PATH} task3")
        expect(stdout).to include "subtask3_1"
      end
    end

    it "passes arguments from Runfile" do
      Dir.chdir("#{__dir__}/fixtures/tasks3") do
        stdout, _, _ = Open3.capture3("#{RUN_PATH} task4 foo bar")
        expect(stdout).to include "foo"
        expect(stdout).to include "bar"
      end
    end
  end

  describe "Run backticks commands" do
    it "runs the command" do
      Dir.chdir("#{__dir__}/fixtures/backticks_commands1") do
        stdout, _, _ = Open3.capture3("#{RUN_PATH} foo")
        expect(stdout).to include "/"
      end
    end

    it "runs a failing command" do
      Dir.chdir("#{__dir__}/fixtures/backticks_commands2") do
        _, stderr, _ = Open3.capture3("#{RUN_PATH} foo")
        expect(stderr).to include "ls: /non_existent_directory: No such file or directory"
      end
    end

    it "runs a non-existent command" do
      Dir.chdir("#{__dir__}/fixtures/backticks_commands3") do
        stdout, _, _ = Open3.capture3("#{RUN_PATH} foo")
        expect(stdout).to include "No such file or directory - non_existent_command"
      end
    end
  end

  describe "Run shell commands" do
    it "runs a valid command" do
      Dir.chdir("#{__dir__}/fixtures/shell_commands1") do
        _, _, status = Open3.capture3("#{RUN_PATH} foo")
        expect(status.exitstatus).to eq 0
      end
    end

    it "fails when the command does not exist" do
      Dir.chdir("#{__dir__}/fixtures/shell_commands2") do
        stdout, _, status = Open3.capture3("#{RUN_PATH} foo")
        expect(stdout).to include "The command has exited"
        expect(status.exitstatus).to eq 3
      end
    end

    it "fails when the command fails" do
      Dir.chdir("#{__dir__}/fixtures/shell_commands3") do
        stdout, _, status = Open3.capture3("#{RUN_PATH} foo")
        expect(stdout).to include "The command has failed"
        expect(status.exitstatus).to eq 3
      end
    end
  end

  # TODO Currently we cannot test this feature because we cannot mock anything since it's
  # run into a subprocess. To be able to test this we need to refactor Run and put those
  # methods in a class.
  describe "Requiring remote files" do
    it "requires a remote file"
    it "uses cache when it exists"
    it "requires an extension"
  end
end
