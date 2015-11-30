require 'spec_helper'

describe Datafile::DB do
  after :each do
    File.delete("#{TEST_SET_1}.db") if File.exists?("#{TEST_SET_1}.db")
    File.delete("#{TEST_SET_2}.db") if File.exists?("#{TEST_SET_2}.db")
    File.delete("#{TEST_SET_3}.db") if File.exists?("#{TEST_SET_3}.db")
  end

  it 'converts a CSV to a SQLite database table' do
    d = Datafile::DB.load("#{TEST_SET_1}.csv")
  end

  it 'properly converts columns to their type specified in the metadata file' do
    rc = 0
    d = Datafile::DB.load("#{TEST_SET_2}.csv") do |record|
      case rc
      when 0
        expect(record["column1"]).to eq("row1value1")
        expect(record["column2"]).to eq(12)
        expect(record["column3"]).to eq(true)
        expect(record["column4"]).to eq(Time.new(2012, 1, 1))
      when 1
        expect(record["column1"]).to eq("row2value1")
        expect(record["column2"]).to eq(22)
        expect(record["column3"]).to eq(true)
        expect(record["column4"]).to eq(Time.new(2012, 1, 2))
      when 2
        expect(record["column1"]).to eq("row3value1")
        expect(record["column2"]).to eq(32)
        expect(record["column3"]).to eq(false)
        expect(record["column4"]).to eq(Time.new(2012, 1, 3))
      when 3
        expect(record["column1"]).to eq("row4value1")
        expect(record["column2"]).to eq(42)
        expect(record["column3"]).to eq(false)
        expect(record["column4"]).to eq(Time.new(2012, 1, 4))
      end
      rc += 1
    end
  end

end

