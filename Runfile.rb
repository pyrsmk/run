require "rubygems"

version 3

# Deploy to an environment
task :deploy do |env, region = "us-east-1", verbose: false, retries: 3|
  run "echo #{env}"
end

task :long_tasks do
  bind :long_task1, :long_task2
end

task :long_task1 do
  run "sleep 5"
end

task :long_task2 do
  run "sleep 10"
end
