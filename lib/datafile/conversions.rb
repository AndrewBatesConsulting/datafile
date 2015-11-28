require "datafile/conversions/bool"
require "datafile/conversions/date"
require "datafile/conversions/int"

module Datafile
  module Conversions
    def self.convert string
      return Converter.new(string)
    end

    class Converter
      attr_reader :string
      def initialize string
        @string = string
      end

      def to type
        send("to_#{type}")
      end
    end
  end
end
