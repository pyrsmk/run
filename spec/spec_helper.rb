require "open3"
require "ostruct"
require "securerandom"

Dir.glob(
  File.join(__dir__, "..", "src", "{monkey,gemspec,markdown,version,run}", "**", "*.rb"),
  &method(:require)
)
