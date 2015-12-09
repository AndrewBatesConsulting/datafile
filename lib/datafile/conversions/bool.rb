module Datafile
  module Conversions
    class Converter
      def to_boolean
        to_bool
      end

      def to_bool
        return object if object.is_a?(TrueClass) or object.is_a?(FalseClass)

        b = false
        if object =~ /^true$/i
          b = true
        elsif object =~ /^false$/i
          b = false
        elsif object =~ /^1$/
          b = true
        elsif object =~ /^0$/
          false
        end
        return b
      end
    end
  end
end
