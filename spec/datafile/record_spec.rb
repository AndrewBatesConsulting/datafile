require 'spec_helper'

describe Datafile::Record do
  class TestRecord < Datafile::Record
    column name: "key", type: "string"
    column name: "column2", type: "int"
    column name: "column3", type: "bool"
    column name: "row_start", type: "date"
    column name: "row_end", type: "date"
    row_start :row_start
    row_end :row_end
  end

  class TestRecord1 < Datafile::Record
    column name: "key1", type: "string"
    column name: "key2", type: "string"
    column name: "row_start", type: "date"
    column name: "row_end", type: "date"
    row_start :row_start
    row_end :row_end
    where "key2='1'"
  end

  class TestRecord2 < Datafile::Record
    column name: "key1", type: "string"
    column name: "key2", type: "string"
    column name: "row_start", type: "date"
    column name: "row_end", type: "date"
    row_start :row_start
    row_end :row_end
    where "key2='2'"
  end

  after :each do
    File.delete("#{TEST_SET_1}.db") if File.exists?("#{TEST_SET_1}.db")
    File.delete("#{TEST_SET_2}.db") if File.exists?("#{TEST_SET_2}.db")
    File.delete("#{TEST_SET_3}.db") if File.exists?("#{TEST_SET_3}.db")
    File.delete("#{TEST_SET_4}.db") if File.exists?("#{TEST_SET_4}.db")
  end

  it 'can unmarshal a hash' do
    r = Datafile::Record.from_row("c1" => "v1", "c2" => "v2", "c3" => "v3")
    expect(r["c1"]).to eq("v1")
    expect(r["c2"]).to eq("v2")
    expect(r["c3"]).to eq("v3")
  end

  it 'can indicate equivalence with another record' do
    r1 = Datafile::Record.from_row("key"=>"key1","column2"=>12,"column3"=>true,"row_start"=>Time.new(2012,1,1),"row_end"=>Time.new(2012,1,2))
    r2 = Datafile::Record.from_row("key"=>"key1","column2"=>12,"column3"=>true,"row_start"=>Time.new(2012,1,1),"row_end"=>Time.new(2012,1,2))
    expect(r1 == r2).to be(true)
  end

  it 'converts values based on column definitions' do
    r = TestRecord.from_row("key" => "key", "column2" => "12", "column3" => "false", "row_start" => "2012-01-01", "row_end" => "2012-01-02")
    expect(r["key"]).to eq("key")
    expect(r["column2"]).to eq(12)
    expect(r["column3"]).to eq(false)
    expect(r["row_start"]).to eq(Time.new(2012,1,1))
    expect(r["row_end"]).to eq(Time.new(2012,1,2))
  end

  it 'requires a row_start field' do
    expect {
      Datafile::Record.row_start
    }.to raise_error("a row_start field must be supplied")
    TestRecord.row_start
  end

  it 'requires a row_end field' do
    expect {
      Datafile::Record.row_end
    }.to raise_error("a row_end field must be supplied")
    TestRecord.row_end
  end

  it 'returns the first record based on key and row_start' do
    Datafile::DB.load("#{TEST_SET_3}.csv", record_class: TestRecord)
    expect(TestRecord.first(key: "key1")).to eq(Datafile::Record.from_row("key"=>"key1","column2"=>12,"column3"=>true,"row_start"=>Time.new(2012,1,1),"row_end"=>Time.new(2012,1,2)))
    expect(TestRecord.first(key: "key2")).to eq(Datafile::Record.from_row("key"=>"key2","column2"=>12,"column3"=>true,"row_start"=>Time.new(2012,1,1),"row_end"=>Time.new(2012,1,2)))
  end

  it 'returns the last record based on key and row_end' do
    Datafile::DB.load("#{TEST_SET_3}.csv", record_class: TestRecord)
    expect(TestRecord.last(key: "key1")).to eq(Datafile::Record.from_row("key"=>"key1","column2"=>42,"column3"=>false,"row_start"=>Time.new(2012,1,4),"row_end"=>nil))
    expect(TestRecord.last(key: "key2")).to eq(Datafile::Record.from_row("key"=>"key2","column2"=>42,"column3"=>false,"row_start"=>Time.new(2012,1,4),"row_end"=>nil))
  end

  it 'allows results to be filtered by a class level where clause' do
    Datafile::DB.load("#{TEST_SET_4}.csv", record_class: TestRecord1)
    expect(TestRecord1.last(key1: "key1")).to eq(Datafile::Record.from_row("key1"=>"key1","key2"=>1,"row_start"=>Time.new(2012,1,2),"row_end"=>Time.new(2012,1,3)))
    expect(TestRecord2.first(key1: "key1")).to eq(Datafile::Record.from_row("key1"=>"key1","key2"=>2,"row_start"=>Time.new(2012,1,3),"row_end"=>Time.new(2012,1,4)))
    expect(TestRecord2.last(key1: "key1")).to eq(Datafile::Record.from_row("key1"=>"key1","key2"=>2,"row_start"=>Time.new(2012,1,4),"row_end"=>nil))
  end
end
