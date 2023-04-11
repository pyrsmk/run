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
        _, _, status = Open3.capture3("../bin/run")
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
    it "runs the task" do
      Dir.chdir("#{__dir__}/fixtures/tasks6") do
        stdout, _, status = Open3.capture3("#{RUN_PATH} foo_bar")
        expect(stdout).to include "foobar"
        expect(status.exitstatus).to eq 0
      end
    end

    it "does not fail if task has hyphens instead of underscores" do
      Dir.chdir("#{__dir__}/fixtures/tasks6") do
        stdout, _, status = Open3.capture3("#{RUN_PATH} foo-bar")
        expect(stdout).to include "foobar"
        expect(status.exitstatus).to eq 0
      end
    end

    it "fails if first parameter is not a symbol" do
      Dir.chdir("#{__dir__}/fixtures/tasks1") do
        stdout, _, status = Open3.capture3(RUN_PATH)
        expect(stdout.chomp).to include "First task parameter must be a symbol"
        expect(status.exitstatus).to eq 6
      end
    end

    it "fails if second parameter is not a string" do
      Dir.chdir("#{__dir__}/fixtures/tasks2") do
        stdout, _, status = Open3.capture3(RUN_PATH)
        expect(stdout.chomp).to include "Second task parameter must be a string"
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

  describe "Help" do
    it "shows help screen by default" do
      Dir.chdir("#{__dir__}/fixtures/help") do
        stdout, _, _ = Open3.capture3(RUN_PATH)
        expect(stdout).to include "Run"
        expect(stdout).to include "test1"
        expect(stdout).to include "help1"
        expect(stdout).to include "test2"
        expect(stdout).to include "help2"
      end
    end

    it "shows help screen when required" do
      Dir.chdir("#{__dir__}/fixtures/help") do
        stdout, _, _ = Open3.capture3(RUN_PATH)
        expect(stdout).to include "Run"
        expect(stdout).to include "test1"
        expect(stdout).to include "help1"
        expect(stdout).to include "test2"
        expect(stdout).to include "help2"
      end
    end

    [
      { token: "**", expectation: "\033[1mhelp3\033[0m" },
      { token: "**", expectation: "foo\033[1mhelp4\033[0mbar" },
      { token: "**", expectation: "\033[1mhelp5\033[0mfoobar\033[1mhelp5\033[0m" },
      { token: "__", expectation: "\033[1mhelp6\033[0m" },
      { token: "__", expectation: "foo\033[1mhelp7\033[0mbar" },
      { token: "__", expectation: "\033[1mhelp8\033[0mfoobar\033[1mhelp8\033[0m" },
      { token: "`",  expectation: "\033[36mhelp9\033[0m" },
      { token: "`",  expectation: "foo\033[36mhelp10\033[0mbar" },
      { token: "`",  expectation: "\033[36mhelp11\033[0mfoobar\033[36mhelp11\033[0m" },
      { token: "*",  expectation: "\033[3mhelp12\033[0m" },
      { token: "*",  expectation: "foo\033[3mhelp13\033[0mbar" },
      { token: "*",  expectation: "\033[3mhelp14\033[0mfoobar\033[3mhelp14\033[0m" },
      { token: "_",  expectation: "\033[3mhelp15\033[0m" },
      { token: "_",  expectation: "foo\033[3mhelp16\033[0mbar" },
      { token: "_",  expectation: "\033[3mhelp17\033[0mfoobar\033[3mhelp17\033[0m" },
    ].each do |test|
      it "converts Markdown (token: #{test[:token]})" do
        Dir.chdir("#{__dir__}/fixtures/help") do
          stdout, _, _ = Open3.capture3(RUN_PATH)
          expect(stdout).to include test[:expectation]
        end
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

    it "passes options from Runfile" do
      Dir.chdir("#{__dir__}/fixtures/tasks3") do
        stdout, _, _ = Open3.capture3("#{RUN_PATH} task4")
        expect(stdout).to include "option1=1"
        expect(stdout).to include "option2=2"
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

  describe "are_you_sure?" do
    let(:yes) { ["Y", "y", "YES", "yes"].sample }
    let(:no) { ["N", "n", "NO", "no", SecureRandom.hex].sample }

    it "does not fail if the answer is `yes`" do
      Dir.chdir("#{__dir__}/fixtures/helpers1") do
        stdout, _, status = Open3.capture3("#{RUN_PATH} foo", stdin_data: "#{yes}\n")
        expect(status.exitstatus).to eq 0
      end
    end

    it "exits if the answer is `no`" do
      Dir.chdir("#{__dir__}/fixtures/helpers1") do
        stdout, _, status = Open3.capture3("#{RUN_PATH} foo", stdin_data: "#{no}\n")
        expect(status.exitstatus).to eq 9
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
