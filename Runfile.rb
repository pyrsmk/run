require "rubygems"

# Run the tests.
task [:specs, :tests] do |dir = "spec/src"|
  run :rspec, dir
end

task :quiet do
  run "rg test /Users/aurelien", quiet: true
end
