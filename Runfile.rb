require "rubygems"

task :quiet do
  run "rg test /Users/aurelien", quiet: true
end
