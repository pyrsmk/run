require "rubygems"

task :puts do
  puts "lol"
end

task :quiet1 do
  run :puts
end

task :quiet2 do
  run "echo 'wtf'"
end
