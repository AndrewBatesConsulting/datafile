require "csv"

module Datafile
  class DB
    def self.instance
      @db
    end

    def self.load sourcefile, options={}, &block
      (metadatafile, dbfile) = self.files(sourcefile)

      raise "#{metadatafile} metadata file does not exists!" unless ::File.exists?(metadatafile)
      metadata = Metadata.from_json(::File.read(metadatafile))

      raise "#{dbfile} database already exists!" if ::File.exists?(dbfile)
      @dbh = SQLite3::Database.new("#{dbfile}")
      
      @dbh.results_as_hash = true
      @db = self.new(@dbh, metadata, options)

      insert_sql = metadata.insert_string

      begin
        # Create the table
        begin
          @dbh.execute(metadata.create_string)
        rescue => e
          STDERR.puts "Failed to create table: #{e}"
          STDERR.puts "SQL: #{metadata.create_string}"
          raise e
        end

        currentRow = nil
        line = 1
        CSV.foreach(sourcefile, :headers => :first_row, :encoding => 'ISO-8859-1') do |row|
          line += 1
          currentRow = row
          begin
            record = Record.from_row(@db.convert_row(row))
            block.call(record) unless block.nil?
          rescue => e
            new_e = e.class.new("Line #{line}: #{e}")
            new_e.set_backtrace(e.backtrace)
            raise new_e
          end

          @db << [insert_sql, record.values(metadata.columns.names)]
        end

        @db.flush
      rescue => e 
        ::File.delete(dbfile) if ::File.exist?(dbfile)
        STDERR.puts "Error on line #{line}: #{currentRow.inspect}"
        raise e
      end
      return @db
    end

    def self.open sourcefile, options={}
      (metadatafile, dbfile) = self.files(sourcefile)

      raise "#{metadatafile} metadata file does not exist!" unless ::File.exists?(metadatafile)
      metadata = Metadata.from_json(::File.read(metadatafile))

      raise "#{dbfile} database doest not exist!" unless ::File.exists?(dbfile)

      @dbh = SQLite3::Database.new("#{dbfile}")
      @dbh.results_as_hash = true
      @db = DB.new(@dbh, metadata, options)
      @db
    end

    def << statement
      @statements << statement
      if @statements.length == @options[:flush_interval]
        flush
      end
    end

    def execute sql, bind_vars = [], *args, &block
      @dbh.execute(sql, bind_vars, *args, &block)
    end

    def fields
      return @dbh.execute("pragma table_info(data)").map { |row| row['name'] }
    end

    def flush
      @dbh.transaction do |db|
        @statements.each do |statement, values|
          @dbh.execute(statement, values)
        end
      end
      @statements = []
    end

    def convert_row row
      new_row = row.dup
      row.each do |field, value|
        value = nil if value =~ /^\s*$/
        new_row[field] = value
        unless value.nil? or @metadata.columns[field].nil?
          type = @metadata.columns[field].type
          new_row[field] = Conversions.convert(value).to(type) if type != "string"
        end
      end
      new_row
    end

    private
      def self.files sourcefile
        dir = ::File.dirname(sourcefile)
        metadatafile = "#{dir}/#{::File.basename(sourcefile, '.*')}.json"
        dbfile = "#{dir}/#{::File.basename(sourcefile, '.*')}.db"

        return metadatafile, dbfile
      end

      def initialize dbh, metadata, options={}
        @dbh = dbh
        @metadata = metadata
        @options = options
        @options[:flush_interval] ||= 100
        @statements = []
      end

  end
end
