require "csv"

module Datafile
  class DB
    def self.load sourcefile, options={}, &block
      (metadatafile, dbfile) = self.files(sourcefile)

      raise "#{metadatafile} metadata file does not exists!" unless ::File.exists?(metadatafile)
      metadata = Metadata.from_json(::File.read(metadatafile))

      raise "#{dbfile} database already exists!" if ::File.exists?(dbfile)
      dbh = SQLite3::Database.new("#{dbfile}")
      db = DB.new(dbh, metadata, options)

      insert_sql = metadata.insert_string

      begin
        # Create the table
        begin
          dbh.execute(metadata.create_string)
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
            # perform type conversions
            row.each do |field, value|
              unless metadata.columns[field].nil?
                type = metadata.columns[field].type
                row[field] = Conversions.convert(value).to(type) if type != "string"
              end
            end
            record = Record.from_row(row)
            block.call(record) unless block.nil?
          rescue => e
            new_e = e.class.new("Line #{line}: #{e}")
            new_e.set_backtrace(e.backtrace)
            raise new_e
          end

          db << [insert_sql, record.values(metadata.columns.names)]
        end

        db.flush
      rescue => e 
        ::File.delete(dbfile) if ::File.exist?(dbfile)
        STDERR.puts "Error on line #{line}: #{currentRow.inspect}"
        raise e
      end
      return db
    end

    def self.open sourcefile, options={}
      (metadatafile, dbfile) = self.files(sourcefile)

      raise "#{metadatafile} metadata file does not exist!" unless ::File.exists?(metadatafile)
      metadata = Metadata.from_json(::File.read(metadatafile))

      raise "#{dbfile} database doest not exist!" unless ::File.exists?(dbfile)

      DB.new(SQLite3::Database.new("#{dbfile}"), metadata, options)
    end

    def << statement
      @statements << statement
      if @statements.length == @options[:flush_interval]
        flush
      end
    end

    def flush
      @dbh.transaction do |db|
        @statements.each do |statement, values|
          @dbh.execute(statement, values)
        end
      end
      @statements = []
    end

    def fields
      return @db.execute("pragma table_info(data)").map { |row| row['name'] }
    end

    def object_count source
      return @db.execute("select count(distinct(CONTRACT_NUMBER)) as COUNT from data where ROW_SOURCE=?", source)[0]["COUNT"]
    end

    def sf_object_count
      @sf_object_count ||= object_count("SALESFORCE")
      return @sf_object_count
    end

    def appx_object_count
      @appx_object_count ||= object_count("APPX")
      return @appx_object_count
    end

    def analysis &block
      SFRecord.all(false) do |sf_object|
        key = sf_object['CONTRACT_NUMBER']
        appx_object = APPXRecord.last(key)
        next if appx_object.nil?

        changed = false
        changed_object = {}
        sf_object.each do |field, new_value|
          old_value = appx_object[field]
          if Differs[field].nil?
            changed_object[field] = DefaultDiffer.diff(new_value, old_value)
          else
            changed_object[field] = Differs[field].diff(new_value, old_value)
          end
          changed = true if changed_object[field] != new_value
        end

        # Correct manually updated fields
        latest = SFRecord.last(sf_object['CONTRACT_NUMBER'])
        latest.each do |field, value|
          value = "<<<NIL>>>" if (value.nil? or (value.is_a?(String) and value.empty?))
          if changed_object[field].is_a?(Hash) and changed_object[field][:new] != value
            changed_object[field] = value
          end
        end

        block.call(changed_object) if (changed && !block.nil?)
      end
    end

    private
      def initialize dbh, metadata, options={}
        @dbh = dbh
        @metadata = metadata
        @options = options
        @options[:flush_interval] ||= 100
        @statements = []
      end

      def self.files sourcefile
        dir = ::File.dirname(sourcefile)
        metadatafile = "#{dir}/#{::File.basename(sourcefile, '.*')}.json"
        dbfile = "#{dir}/#{::File.basename(sourcefile, '.*')}.db"

        return metadatafile, dbfile
      end

  end
end
