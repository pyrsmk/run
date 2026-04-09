require "rubygems"

task :test do |foo: false|
  puts foo ? "true" : "false"
end
