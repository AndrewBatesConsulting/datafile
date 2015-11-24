require 'spec_helper'

describe Datafile::DB do
  it 'converts a CSV to a SQLite database table' do
    d = Datafile::DB.load("#{TEST_SET_1}.csv")
    File.delete("#{TEST_SET_1}.db")
  end
end
