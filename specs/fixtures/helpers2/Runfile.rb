task :test1 do
  choice = menu("?", ["foo", "bar"])
  puts "Choice: #{choice}"
end

task :test2 do
  choice = menu("?", {"Foo" => "foo", "Bar" => "bar"})
  puts "Choice: #{choice}"
end

task :test3 do
  menu("", ["", 0, false].sample)
end
