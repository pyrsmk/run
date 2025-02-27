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
      contents = URI.parse(@url).open.read
      matches = /^\s*s.version\s*=\s*"(.+?)"\s*$/.match(contents)
      raise UnreachableError.new if matches.nil?
      matches[1]
    rescue SocketError
      raise UnreachableError.new
    end
  end
end
