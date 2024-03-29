task :task1 do
  puts "task1"
end

task :task2 do |*args|
  args.each { |value| puts value }
end

task :task3 do
  run :subtask3_1
end

task :subtask3_1 do
  puts "subtask3_1"
end

task :task4 do |*args|
  run :subtask4_1, *args, option1: 1, option2: 2
end

task :subtask4_1 do |*args, **options|
  args.each { |value| puts value }
  options.each { |key, value| puts "#{key}=#{value}" }
end
