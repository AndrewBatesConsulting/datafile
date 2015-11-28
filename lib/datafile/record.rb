module Datafile
  class Record
    extend Forwardable
    def_delegators :@row, :[], :[]=, :each, :to_s, :inspect

    def self.from_row row
      record = self.new
      row.each do |field, value|
        record[field] = value
      end
      record
    end

    def values fields
      return fields.map { |field| @row[field].to_s }
    end

    private
      def initialize
        @row = {}
=begin
        @row.each do |field, value|
        begin
          if Converters[field].nil?
            @row[field] = DefaultConverter.convert(value)
          else
            @row[field] = Converters[field].convert(value)
          end
        rescue => e
          new_e = e.class.new("Column #{field} #{e}")
          new_e.set_backtrace(e.backtrace)
          raise new_e
        end
        end
=end
      end

  end
end
