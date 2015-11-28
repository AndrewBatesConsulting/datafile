module Datafile
  module Conversions
    class Converter
      def to_date
        if string =~ /^\d{1,2}\/\d{1,2}\/\d{4}$/
          return Time.strptime(string, "%m/%d/%Y")
        elsif string =~ /^\d{1,2}\/\d{1,2}\/\d{2}$/
          return Time.strptime(string, "%m/%d/%y")
        elsif string =~ /^\d{1,2}-\d{1,2}-\d{2,4}$/
          return Time.strptime(string, "%m-%d-%y")
        elsif string =~ /^\d{1,2}\/\d{1,2}\/\d{4} \d{2}:\d{2}$/
          return Time.strptime(string, "%m/%d/%Y %H:%M")
        elsif string =~ /^\d{1,2}\/\d{1,2}\/\d{2} \d{1,2}:\d{2}$/
          return Time.strptime(string, "%m/%d/%y %H:%M")
        elsif string =~ /^\d{1,2}\/\d{1,2}\/\d{4} \d{2}:\d{2}:\d{2}$/
          return Time.strptime(string, "%m/%d/%Y %H:%M:%S")
        elsif string =~ /^\d{1,2}\/\d{1,2}\/\d{2} \d{2}:\d{2}:\d{2}$/
          return Time.strptime(string, "%m/%d/%y %H:%M:%S")
        elsif string =~ /^\d{4}\-\d{2}-\d{2}$/
          return Time.strptime(string, "%Y-%m-%d")
        elsif string =~ /^\d{4}\-/
          return Time.strptime(string, "%Y-%m-%d %H:%M:%S")
        else
          raise "Invalid time format for #{string}"
        end
      end
    end
  end
end
