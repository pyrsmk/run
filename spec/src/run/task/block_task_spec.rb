# frozen_string_literal: true

require_relative "../../../../src/run/task/block_task"

RSpec.describe Run::Task::BlockTask do
  def forward(*arguments, **options)
    options.delete(:quiet)
    yield(*arguments, **options)
  end

  it "keeps the default value of a parameter when no options are given" do
    received = nil
    task = Run::Task::BlockTask.new { |env = "develop"| received = env }

    forward { |*arguments, **options| task.run(*arguments, **options) }

    expect(received).to eq("develop")
  end

  it "does not shift positional arguments when no options are given" do
    received = nil
    task = Run::Task::BlockTask.new { |env = "develop", queue = "all"| received = [env, queue] }

    forward("local") { |*arguments, **options| task.run(*arguments, **options) }

    expect(received).to eq(["local", "all"])
  end

  it "passes named parameters to a block that accepts them" do
    received = nil
    task = Run::Task::BlockTask.new { |env = "develop", draft: false| received = [env, draft] }

    task.run("local", draft: true)

    expect(received).to eq(["local", true])
  end
end
