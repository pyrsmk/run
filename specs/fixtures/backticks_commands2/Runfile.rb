task :foo do
  puts `ls /non_existent_directory`
end
