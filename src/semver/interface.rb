module SemVer
  module SemVerInterface < Interface
    # @return [Array<Symbol>]
    def self.declare_interface_methods
      [:major, :minor, :patch, :<, :>, :==]
    end
  end
end
