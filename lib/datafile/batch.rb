module Datafile
  class Batch
    def initialize sql_string, interval=100
      @sql_string = sql_string
      @interval = interval
      @rows = []
    end

    def << values
      @rows << values
      flush
    end

    def flush
      if @rows == @interval
        Datafile.db.transaction do |db|
          @rows.each do |row|
            Datafile.db.execute(@sql_string, row)
          end
        end
        @rows = []
      end
    end
  end
end
