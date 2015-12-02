require 'spec_helper'

describe Datafile::DB do
  class TestRecord < Datafile::Record
    column name: "column1", type: "string"
    column name: "column2", type: "string"
    column name: "column3", type: "string"
    column name: "column4", type: "string"
  end

  it 'converts a CSV to a SQLite database table' do
    d = Datafile::DB.load("#{TEST_SET_1}.csv", record_class: TestRecord)
  end
end

