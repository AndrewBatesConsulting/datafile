require "csv"

module Datafile
  class DB
    def self.instance
      @db
    end

    def self.load sourcefile, options={}, &block
      #options[:record_class] ||= Datafile::Record

      dbfile = self.files(sourcefile)

      raise "#{dbfile} database already exists!" if ::File.exists?(dbfile)
      @dbh = SQLite3::Database.new("#{dbfile}")
      
      @dbh.results_as_hash = true
      @db = self.new(@dbh, options)

      begin
        currentRow = nil
        line = 1
        CSV.foreach(sourcefile, :headers => :first_row, :encoding => 'ISO-8859-1') do |row|
          line += 1
          currentRow = row
          begin
            record = options[:record_class].from_row(row)
            block.call(record) unless block.nil?
          rescue => e
            new_e = e.class.new("Line #{line}: #{e}")
            new_e.set_backtrace(e.backtrace)
            raise new_e
          end

          @db << record
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
      dbfile = self.files(sourcefile)

      raise "#{dbfile} database doest not exist!" unless ::File.exists?(dbfile)

      @dbh = SQLite3::Database.new("#{dbfile}")
      @dbh.results_as_hash = true
      @db = DB.new(@dbh, options)
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

    def data_table_created?
      return @dbh.table_info("data").length > 0
    end

    def flush
      return if @statements.length == 0

      unless data_table_created?
        # Create the table
        begin
          @dbh.execute(@options[:record_class].create_string)
        rescue => e
          raise e
        end
      end

      @dbh.transaction do |db|
        @statements.each do |record|
          record.insert(@dbh)
        end
      end
      @statements = []
    end

    private
      def self.files sourcefile
        dir = ::File.dirname(sourcefile)
        #metadatafile = "#{dir}/#{::File.basename(sourcefile, '.*')}.json"
        dbfile = "#{dir}/#{::File.basename(sourcefile, '.*')}.db"

        return dbfile
      end

      def initialize dbh, options={}
        @dbh = dbh
        @options = options
        @options[:flush_interval] ||= 100
        @statements = []
      end

  end
end
