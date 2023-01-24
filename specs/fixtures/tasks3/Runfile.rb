task :task1 do
  puts "task1"
end

task :task2 do |*args|
  args.each { |value| puts value }
end

task :task3 do
  call :subtask3_1
end

task :subtask3_1 do
  puts "subtask3_1"
end

task :task4 do |*args|
  call :subtask4_1, *args
end

task :subtask4_1 do |*args|
  args.each { |value| puts value }
end
