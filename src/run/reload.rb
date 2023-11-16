module Run
  module Reload
    # @return [void]
    def run
      run "run #{$*}"
      exit
    end
  end
end
