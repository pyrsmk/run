module Run
  module Core
    class Registry
      @@registry = {}

      def self.[]=(key, value)
        @@registry[key] = value
      end

      def self.[](key)
        @@registry[key]
      end

      def self.delete(key)
        @@registry.delete(key)
      end
    end
  end
end
