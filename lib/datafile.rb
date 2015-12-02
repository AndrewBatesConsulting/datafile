require "datafile/batch"
require "datafile/columns"
require "datafile/column_def"
require "datafile/conversions"
require "datafile/db"
require "datafile/record"
require "datafile/version"
require "json"
require "sqlite3"

module Datafile
  class DefaultDiffer
    def self.diff new_value, old_value
      cn = new_value
      co = old_value
      if new_value.is_a?(String)
        cn = new_value.downcase.strip
        co = old_value.downcase.strip unless old_value.nil?
      end

      if cn != co
        if (cn.nil? || cn.empty?) && !(co.nil? || co.empty?)
          new_value = "<<<NIL>>>"
        end
        return { old: old_value, new: new_value }
      end
      return new_value
    end
  end

  class NonDiffer
    def self.diff new_value, old_value
      return new_value
    end
  end

  Differs = {
    "ROW_SOURCE" => NonDiffer,
    "ROW_LATEST_FLAG" => NonDiffer,
    "ROW_START_DATE" => NonDiffer,
    "ROW_END_DATE" => NonDiffer,
    "CONTRACT_NUMBER" => NonDiffer,
  }
end
