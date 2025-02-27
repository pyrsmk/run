require "shellwords"

module Run
  module Helper
    class ExpandHelper
      # @param glob [String]
      def initialize(glob)
        @glob = glob
      end

      # @return [String] space-separated list of found paths
      def run
        Dir.glob(@glob)
           .each_with_object([]) do |path, paths|
             next if File.directory?(path)
             paths << File.realpath(path).shellescape
           end
           .join(" ")
      end
    end
  end
end
