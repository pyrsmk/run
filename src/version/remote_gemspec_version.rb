require "open-uri"
require "socket"

module Version
  class RemoteGemspecVersion
    # @param url [String]
    def initialize(url)
      @url = url
    end

    # @return [String]
    def extract
      # `mode` and `perm` options are not used, but we need to set them in order to set
      # options...
      contents = URI.parse(@url).open("r", 0666, open_timeout: 1, read_timeout: 1).read
      matches = /^\s*s.version\s*=\s*"(.+?)"\s*$/.match(contents)
      raise UnreachableError.new if matches.nil?
      matches[1]
    rescue SocketError
      raise UnreachableError.new
    end
  end
end
