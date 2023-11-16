require "open3"
require "securerandom"

RUN_PATH = "#{__dir__}/../bin/run"

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
        expect(stdout.chomp).to include "'name' must be a Symbol"
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
        _, _, status = Open3.capture3("#{RUN_PATH} foo", stdin_data: "#{yes}\n")
        expect(status.exitstatus).to eq 0
      end
    end

    it "exits if the answer is `no`" do
      Dir.chdir("#{__dir__}/fixtures/helpers1") do
        _, _, status = Open3.capture3("#{RUN_PATH} foo", stdin_data: "#{no}\n")
        expect(status.exitstatus).to eq 9
      end
    end
  end

  describe "menu" do
    let(:choice) { [[1, "foo"], [2, "bar"]].sample }

    context "when using an Array for choices parameter" do
      it "displays the menu" do
        Dir.chdir("#{__dir__}/fixtures/helpers2") do
          stdout, _, status = Open3.capture3("#{RUN_PATH} test1", stdin_data: "#{choice[0]}\n")
          expect(stdout).to include "1. foo\n"
          expect(stdout).to include "2. bar\n"
          expect(stdout).to include "?\n"
          expect(stdout).to include "Choice: #{choice[1]}"
          expect(status.exitstatus).to eq 0
        end
      end
    end

    context "when using a Hash for choices parameter" do
      it "displays a menu" do
        Dir.chdir("#{__dir__}/fixtures/helpers2") do
          stdout, _, status = Open3.capture3("#{RUN_PATH} test2", stdin_data: "#{choice[0]}\n")
          expect(stdout).to include "1. Foo\n"
          expect(stdout).to include "2. Bar\n"
          expect(stdout).to include "?\n"
          expect(stdout).to include "Choice: #{choice[1]}"
          expect(status.exitstatus).to eq 0
        end
      end
    end

    it "fails if the choices parameter is not an Array or a Hash" do
        Dir.chdir("#{__dir__}/fixtures/helpers2") do
          stdout, _, status = Open3.capture3("#{RUN_PATH} test3")
          expect(stdout.chomp).to include "'choices' must be an Array or an Hash"
          expect(status.exitstatus).to eq 6
        end
    end
  end
end
