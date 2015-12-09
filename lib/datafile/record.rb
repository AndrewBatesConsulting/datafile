module Datafile
  class Record
    extend Forwardable
    def_delegators :@row, :[], :[]=, :each, :to_s, :inspect

    def self.all latest=true, &block
      having = latest ? "MAX(#{self.row_start}) AND MAX(#{self.row_end})" : "MIN(#{self.row_start}) AND MIN(#{self.row_end})"
      query = nil
      if self.where.nil?
        query = "SELECT * FROM data GROUP BY CONTRACT_NUMBER HAVING #{having}"
      else
        query = "SELECT * FROM data WHERE #{self.where} GROUP BY CONTRACT_NUMBER HAVING #{having}"
      end

      Datafile::DB.instance.execute(query) do |row|
        block.call(self.from_row(row)) unless block.nil? || row.nil?
      end
    end

    def self.column columndef
      @columns ||= Columns.new
      if columndef.is_a? Hash
        columndef = ColumnDef.from_hash(columndef)
      end
      define_method(columndef.name.downcase) do
        instance_variable_get(:@row)[columndef.name]
      end
      @columns << columndef
    end

    def self.columns
      columns = @columns || Columns.new
      if self.superclass.respond_to?(:columns)
        supercolumns = self.superclass.columns
        columns = columns + supercolumns unless supercolumns.nil?
      end
      return columns
    end

    def self.create_string
      create_string = "create table data (\n\t"
      create_string += self.columns.map { |column| column.to_create }.join(",\n")
      create_string += "\n);\n"
      create_string
    end

    def self.first keys
      key_clause = keys.map{ |key,value| "#{key}=?"}.join(" AND ")
      key_clause = "#{where} AND #{key_clause}" unless where.nil?

      row = Datafile::DB.instance.execute("SELECT * FROM data WHERE #{key_clause} ORDER BY #{row_start}, #{row_end} ASC LIMIT 1", keys.values)[0]
      from_row(row)
    end

    def self.from_row row
      return nil if row.nil?
      record = self.new
      row.each do |column, value|
        next if column.is_a?(Numeric)
        value = nil if value =~ /^\s*$/
        unless value.nil? or self.columns[column].nil?
          type = self.columns[column].type
          value = Conversions.convert(value).to(type) if type != "string"
        end
        record[column] = value
      end
      record
    end

    def self.insert_string
      "INSERT INTO data (#{self.columns.names.join(",")}) VALUES (?#{',?'*(self.columns.names.length-1)})"
    end

    def self.last keys
      key_clause = keys.map{ |key,value| "#{key}=?"}.join(" AND ")
      key_clause = "#{where} AND #{key_clause}" unless where.nil?

      row = Datafile::DB.instance.execute("SELECT * FROM data WHERE #{key_clause} ORDER BY #{row_start} desc LIMIT 1", keys.values)[0]
      from_row(row)
    end

    def self.row_end row_end_field=nil
      if row_end_field.nil? 
        if @row_end.nil? && self.superclass.respond_to?(:row_end)
          return self.superclass.row_end
        end

        return @row_end || raise("a row_end field must be supplied")
      end

      @row_end = row_end_field
    end

    def self.row_start row_start_field=nil
      if row_start_field.nil? 
        if @row_start.nil? && self.superclass.respond_to?(:row_start)
          return self.superclass.row_start
        end

        return @row_start || raise("a row_start field must be supplied")
      end
      @row_start = row_start_field
    end

    def self.where where=nil
      if where.nil?
        return @where
      end
      @where = where
    end

    def == other
      self.class.columns.each do |column|
        return false if @row[column.name] != other[column.name]
      end
      true
    end

    def insert dbh
      dbh.execute(self.class.insert_string, values)
    end

    def values
      return self.class.columns.map { |column| @row[column.name].to_s }
    end

    private
      def initialize
        @row = {}
      end
  end
end
