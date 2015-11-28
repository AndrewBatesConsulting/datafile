module Datafile
  module Conversions
    class Converter
      def to_bool
        b = false
        if string =~ /^true$/i
          b = true
        elsif string =~ /^false$/i
          b = false
        elsif string =~ /^1$/
          b = true
        elsif string =~ /^0$/
          false
        end
        return b
      end
    end
  end
end
