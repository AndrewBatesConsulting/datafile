module Datafile
  class Columns
    extend Forwardable
    def_delegators :@definitions, :[]
    attr_reader :names
    def initialize
      @definitions = {}
      @names = []
    end

    def self.from_hash hash
      columns = self.new
      hash.each do |key, value|
        columns << ColumnDef.from_hash(value)
      end
      columns
    end

    def self.from_json json
      return self.from_hash(JSON.parse(json, symbolize_names: false))
    end

    def << columndef
      self[columndef.name] = columndef
    end

    def []= name, columndef
      raise "Name #{name.inspect} does not match ColumnDef.name #{columndef.name.inspect}" if name != columndef.name
      if @definitions[name].nil?
        @names << name
      end
      @definitions[name] = columndef
    end

    def map &block
      @names.map {|name| block.call(@definitions[name]) }
    end

    def to_hash
      hash = {}
      @definitions.each { |k,v| hash[k] = v.to_hash }
      hash
    end

    def to_json(*a)
      to_hash.to_json(*a)
    end
  end
end
