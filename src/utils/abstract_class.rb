class AbstractClass
  def initialize
    if self.class == AbstractClass
      raise "Cannot instantiate an abstract class"
    end

    declare_abstract_methods.each do |method_name|
      define_method method_name do
        raise "This method must be implemented"
      end
    end
  end

  protected

  # @return [Array<Symbol>]
  def declare_abstract_methods
    raise "This method must be implemented"
  end
end
