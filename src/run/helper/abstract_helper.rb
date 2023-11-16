module Run
  module Helper
    class AbstractHelper < AbstractClass
      protected

      # @return [Array<Symbol>]
      def declare_abstract_methods
        [:name, :run]
      end
    end
  end
end
