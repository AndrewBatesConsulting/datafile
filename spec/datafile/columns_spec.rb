require 'spec_helper'

describe Datafile::Columns do
  test_hash = {
    "c1" => {
      name:"c1",
      type:"string",
    },
    "c2" => {
      name:"c2",
      type:"string",
    }
  }

  test_json = '{"c1":{"name":"c1","type":"string"},"c2":{"name":"c2","type":"string"}}'

  it 'ensures column name matches column definition' do
    expect {
      columns = Datafile::Columns.new
      columns["c2"] = Datafile::ColumnDef.new(name: "c1", type: "string")
    }.to raise_error('Name "c2" does not match ColumnDef.name "c1"')
  end

  it 'can generate a hash' do
    columns = Datafile::Columns.new
    columns["c1"] = Datafile::ColumnDef.new(name: "c1", type: "string")
    columns["c2"] = Datafile::ColumnDef.new(name: "c2", type: "string")

    expect(columns.to_hash).to eq(test_hash)
  end

  it 'can marshal JSON' do
    columns = Datafile::Columns.new
    columns["c1"] = Datafile::ColumnDef.new(name: "c1", type: "string")
    columns["c2"] = Datafile::ColumnDef.new(name: "c2", type: "string")

    expect(columns.to_json).to eq(test_json)
  end

  it 'can unmarshal JSON' do
    columns = Datafile::Columns.from_json(test_json)
    expect(columns.to_hash).to eq(test_hash)
  end
end
