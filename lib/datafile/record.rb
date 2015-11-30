module Datafile
  class Record
    extend Forwardable
    def_delegators :@row, :[], :[]=, :each, :to_s, :inspect

    def self.from_row row
      record = self.new
      row.each do |field, value|
        next if field.is_a?(Numeric)
        record[field] = value
      end
      record
    end

    def self.row_end row_end_field=nil
      if row_end_field.nil? 
        return @row_end || raise("a row_end field must be supplied")
      end
      @row_end = row_end_field
    end

    def self.row_start row_start_field=nil
      if row_start_field.nil? 
        return @row_start || raise("a row_start field must be supplied")
      end
      @row_start = row_start_field
    end

    def self.first keys
      key_clause = keys.map{ |key,value| "#{key}=?"}.join(" AND ")
      key_clause = "#{where} AND #{key_clause}" unless where.nil?

      row = Datafile::DB.instance.execute("SELECT * FROM data WHERE #{key_clause} ORDER BY #{row_start} asc LIMIT 1", keys.values)[0]
      Record.from_row(Datafile::DB.instance.convert_row(row))
    end

    def self.last keys
      key_clause = keys.map{ |key,value| "#{key}=?"}.join(" AND ")
      key_clause = "#{where} AND #{key_clause}" unless where.nil?

      row = Datafile::DB.instance.execute("SELECT * FROM data WHERE #{key_clause} ORDER BY #{row_start} desc LIMIT 1", keys.values)[0]
      Record.from_row(Datafile::DB.instance.convert_row(row))
    end

    def self.where where=nil
      if where.nil?
        return @where
      end
      @where = where
    end

    def values fields
      return fields.map { |field| @row[field].to_s }
    end

    def == other
      @row.each do |field, value|
        return false if value != other[field]
      end
      true
    end

    private
      def initialize
        @row = {}
      end
  end
end
