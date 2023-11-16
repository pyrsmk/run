module Interface
  declare_interface_methods.each do |name|
    define_method name do
      raise "This method must be implemented"
    end
  end

  protected

  # @return [Array<Symbol>]
  def declare_interface_methods
    raise "This method must be implemented"
  end
end
