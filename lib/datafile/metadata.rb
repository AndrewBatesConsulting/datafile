module Datafile
  class Metadata
    attr_reader :columns

    def initialize
      @columns = Columns.new
    end

    def self.from_hash hash
      metadata = self.new
      
      # convert keys to symbols
      hash = hash.inject({}){ |hash, (k, v)| hash.merge( k.to_sym => v )  }
      metadata.instance_variable_set(:@columns, Columns.from_hash(hash[:columns]))
      metadata
    end

    def self.from_json json
      return self.from_hash(JSON.parse(json, symbolize_names: true))
    end

    def << column_def
      @columns[column_def.name] = column_def
    end

    def create_string
      create_string = "create table data (\n\t"
      create_string += @columns.map { |column| column.to_create }.join(",\n")
      create_string += "\n);\n"
      create_string
    end

    def insert_string
      "INSERT INTO data (#{@columns.names.join(",")}) VALUES (?#{',?'*(@columns.names.length-1)})"
    end

    def to_hash
      {
        columns: @columns.to_hash,
      }
    end

    def to_json *a
      to_hash.to_json(*a)
    end
  end
end
