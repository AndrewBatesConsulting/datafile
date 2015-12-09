module Datafile
  module Conversions
    class Converter
      def to_date
        return object if object.is_a?(Time)

        if object =~ /^\d{1,2}\/\d{1,2}\/\d{4}$/
          return Time.strptime(object, "%m/%d/%Y")
        elsif object =~ /^\d{1,2}\/\d{1,2}\/\d{2}$/
          return Time.strptime(object, "%m/%d/%y")
        elsif object =~ /^\d{1,2}-\d{1,2}-\d{2,4}$/
          return Time.strptime(object, "%m-%d-%y")
        elsif object =~ /^\d{1,2}\/\d{1,2}\/\d{4} \d{2}:\d{2}$/
          return Time.strptime(object, "%m/%d/%Y %H:%M")
        elsif object =~ /^\d{1,2}\/\d{1,2}\/\d{2} \d{1,2}:\d{2}$/
          return Time.strptime(object, "%m/%d/%y %H:%M")
        elsif object =~ /^\d{1,2}\/\d{1,2}\/\d{4} \d{2}:\d{2}:\d{2}$/
          return Time.strptime(object, "%m/%d/%Y %H:%M:%S")
        elsif object =~ /^\d{1,2}\/\d{1,2}\/\d{2} \d{2}:\d{2}:\d{2}$/
          return Time.strptime(object, "%m/%d/%y %H:%M:%S")
        elsif object =~ /^\d{4}\-\d{2}-\d{2}$/
          return Time.strptime(object, "%Y-%m-%d")
        elsif object =~ /^\d{4}\-/
          return Time.strptime(object, "%Y-%m-%d %H:%M:%S")
        else
          raise "Invalid time format for #{object}"
        end
      end
    end
  end
end
