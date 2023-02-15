task :test1, "help1" do
end

task :test2, "help2" do
end

# Each token should be able to be rendered twice, in the middle of a word or at string
# start/end.
index = 2
[
  "**",
  "__",
  "`",
  "*",
  "_"
].each do |token|
  task "test#{index += 1}".to_sym, "#{token}help#{index}#{token}" do; end
  task "test#{index += 1}".to_sym, "#{token}help#{index}#{token}" do; end
  task "test#{index += 1}".to_sym, "foo#{token}help#{index}#{token}bar" do; end
  task "test#{index += 1}".to_sym, "foo#{token}help#{index}#{token}bar" do; end
end
