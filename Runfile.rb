require "rubygems"

version 3

task :test do |foo: false|
  puts foo ? "true" : "false"
end
