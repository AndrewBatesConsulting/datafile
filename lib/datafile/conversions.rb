require "datafile/conversions/bool"
require "datafile/conversions/date"
require "datafile/conversions/int"

module Datafile
  module Conversions
    def self.convert object
      return Converter.new(object)
    end

    class Converter
      attr_reader :object
      def initialize object
        @object = object
      end

      def to type
        send("to_#{type}")
      end
    end
  end
end
