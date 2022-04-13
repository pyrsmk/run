require "rubygems"
require "bundler/setup"
require "dotenv/load"
require "aws-sdk-s3"

SOURCE_FILE = "#{__dir__}/src/run.rb"

task :publish do
  # Connect to S3 API.
  raise "SPACES_SECRET is not defined" if !ENV.has_key?("SPACES_SECRET")
  client = Aws::S3::Client.new(
    access_key_id: "LVQGQW47ER7IZFSPFZIM",
    secret_access_key: ENV["SPACES_SECRET"],
    endpoint: "https://fra1.digitaloceanspaces.com",
    region: "fra1"
  )
  # Extract version number.
  version = /^VERSION = "(\d\.\d\.\d)"$/.match(File.read(SOURCE_FILE))
  raise "Cannot extract version number from 'src/run.rb'" if version.nil?
  filename = "run_v#{version[1]}.rb"
  # Pushing files.
  puts "Pushing run_latest.rb..."
  client.put_object({
    bucket: "pyrsmk",
    key: "run/run_latest.rb",
    body: File.read(SOURCE_FILE),
    acl: "public-read"
  })
  puts "Pushing #{filename}..."
  client.put_object({
    bucket: "pyrsmk",
    key: "run/#{filename}",
    body: File.read(SOURCE_FILE),
    acl: "public-read"
  })
  puts "Published."
end
