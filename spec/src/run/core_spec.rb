# frozen_string_literal: true

Dir.glob(File.join(__dir__, "..", "..", "..", "src", "run", "{task,error}", "*.rb"), &method(:require))
require_relative "../../../src/run/core"

RSpec.describe Run::Core do
  describe ".parse_arguments" do
    def parse(*words)
      Run::Core.parse_arguments(words)
    end

    it "keeps a plain word as a string" do
      expect(parse("WizVilleSurvey")).to eq([["WizVilleSurvey"], {}])
    end

    it "keeps accented and hyphenated words as strings" do
      expect(parse("clément", "WIZ-0000", "John Doe")).to eq([["clément", "WIZ-0000", "John Doe"], {}])
    end

    it "keeps a number with a leading zero as a string" do
      expect(parse("007", "00.5")).to eq([["007", "00.5"], {}])
    end

    it "converts integers" do
      expect(parse("42", "0", "-3")).to eq([[42, 0, -3], {}])
    end

    it "converts floats" do
      expect(parse("1.5", "0.25", "-0.5")).to eq([[1.5, 0.25, -0.5], {}])
    end

    it "keeps malformed numbers as strings" do
      expect(parse("1.", ".5", "1e3", "+3", "--3")).to eq([["1.", ".5", "1e3", "+3", "--3"], {}])
    end

    it "converts booleans" do
      expect(parse("true", "false")).to eq([[true, false], {}])
    end

    it "keeps other casings of booleans as strings" do
      expect(parse("True", "FALSE")).to eq([["True", "FALSE"], {}])
    end

    it "converts +name and -name into options" do
      expect(parse("+tunnel", "-draft")).to eq([[], { tunnel: true, draft: false }])
    end

    it "tells -draft apart from -3" do
      expect(parse("-draft", "-3")).to eq([[-3], { draft: false }])
    end

    it "converts name=value into a named parameter" do
      expect(parse("reviewer=clement")).to eq([[], { reviewer: "clement" }])
    end

    it "converts the value of a named parameter" do
      expect(parse("retries=3", "ratio=0.5", "dry=true", "code=007")).to eq(
        [[], { retries: 3, ratio: 0.5, dry: true, code: "007" }]
      )
    end

    it "converts name=a,b into an array" do
      expect(parse("reviewer=clement,morisset")).to eq([[], { reviewer: ["clement", "morisset"] }])
    end

    it "converts each element of an array" do
      expect(parse("ids=1,2,x")).to eq([[], { ids: [1, 2, "x"] }])
    end

    it "gives a scalar for a single element" do
      expect(parse("ids=1")).to eq([[], { ids: 1 }])
    end

    it "keeps empty values" do
      expect(parse("a=", "b=x,", "c=,")).to eq([[], { a: "", b: ["x", ""], c: ["", ""] }])
    end

    it "keeps everything after the first = in the value" do
      expect(parse("query=a=b")).to eq([[], { query: "a=b" }])
    end

    it "replaces hyphens with underscores in names" do
      expect(parse("+dry-run", "max-retries=3")).to eq([[], { dry_run: true, max_retries: 3 }])
    end

    it "keeps words that are not valid names as positional arguments" do
      expect(parse("-", "+", "--draft", "+3", "=x", "1a=x", "a-=x")).to eq(
        [["-", "+", "--draft", "+3", "=x", "1a=x", "a-=x"], {}]
      )
    end

    it "keeps positional arguments and options in order" do
      expect(parse("deploy", "+force", "3", "stage=prod")).to eq([["deploy", 3], { force: true, stage: "prod" }])
    end

    it "examines multiline arguments as a whole" do
      expect(parse("foo\nbar", "+draft\nbar", "42\n43", "true\n")).to eq(
        [["foo\nbar", "+draft\nbar", "42\n43", "true\n"], {}]
      )
    end

    it "keeps newlines in the value of a named parameter" do
      expect(parse("message=foo\nbar")).to eq([[], { message: "foo\nbar" }])
    end

    it "rejects a repeated name" do
      expect { parse("a=1", "a=2") }.to raise_error(Run::Error::DuplicateParameter, "Parameter 'a' is given more than once")
      expect { parse("+a", "a=2") }.to raise_error(Run::Error::DuplicateParameter, "Parameter 'a' is given more than once")
      expect { parse("+a", "-a") }.to raise_error(Run::Error::DuplicateParameter, "Parameter 'a' is given more than once")
      expect { parse("dry-run=1", "+dry_run") }.to raise_error(Run::Error::DuplicateParameter, "Parameter 'dry_run' is given more than once")
    end
  end

  describe ".run" do
    it "passes named parameters to a task declaring keywords" do
      received = nil
      Run::Core.task(:spec_with_keywords) { |*args, reviewer: nil| received = [args, reviewer] }

      Run::Core.run(:spec_with_keywords, "a", reviewer: "clement")

      expect(received).to eq([["a"], "clement"])
    end

    it "passes named parameters to a task declaring a keyword rest" do
      received = nil
      Run::Core.task(:spec_with_keyword_rest) { |**options| received = options }

      Run::Core.run(:spec_with_keyword_rest, reviewer: "clement")

      expect(received).to eq({ reviewer: "clement" })
    end

    it "rejects named parameters for a task without keywords" do
      Run::Core.task(:spec_without_keywords) { |stage, branch = "master"| }

      expect { Run::Core.run(:spec_without_keywords, "prod", reviewer: "x", draft: false) }.to raise_error(
        Run::Error::UnexpectedNamedParameters, "Task 'spec_without_keywords' does not accept named parameters: reviewer, draft"
      )
    end

    it "runs a task without keywords when no named parameter is given" do
      received = nil
      Run::Core.task(:spec_without_keywords_called) { |stage, branch = "master"| received = [stage, branch] }

      Run::Core.run(:spec_without_keywords_called, "prod")

      expect(received).to eq(["prod", "master"])
    end
  end
end
