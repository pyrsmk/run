# help1
task :test1 do
end

# *help2*
task :test2 do
end

# first line
# second line
task :test3 do
end

task :test4 do
end

# Each token should be able to be rendered twice, in the middle of a word or at string
# start/end.
index = 4
[
  "**",
  "__",
  "`",
  "*",
  "_"
].each do |token|
  task "test#{index += 1}".to_sym, "#{token}help#{index}#{token}" do; end
  task "test#{index += 1}".to_sym, "foo#{token}help#{index}#{token}bar" do; end
  task "test#{index += 1}".to_sym, "#{token}help#{index}#{token}foobar#{token}help#{index}#{token}" do; end
end
