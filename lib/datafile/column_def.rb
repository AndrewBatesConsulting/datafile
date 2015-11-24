module Datafile
  class ColumnDef
    attr_reader :name, :type, :key

    def initialize definition={}
      @key = definition[:key] || false
      @name = definition[:name] || raise("Column name must be specified")
      @type = definition[:type] || raise("Column type must be specified")
      unless @key.is_a?(TrueClass) or @key.is_a?(FalseClass)
        raise "Key must be either true or false"
      end
    end

    def self.from_hash hash
      return self.new(hash.inject({}){ |hash, (k, v)| hash.merge( k.to_sym => v )  })
    end

    def self.from_json json
      return self.from_hash(JSON.parse(json, symbolize_names: true))
    end

    def to_hash
      {
        name: @name,
        type: @type,
        key: @key,
      }
    end

    def to_create
      "\t#{@name} #{@type}"
    end

    def to_json(*a)
      to_hash.to_json(*a)
    end
  end
end
