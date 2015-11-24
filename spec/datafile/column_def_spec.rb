require 'spec_helper'

describe Datafile::ColumnDef do
  test_hash = {
    name: "c1",
    type: "string",
    key: true
  }

  test_json = '{"name":"c1","type":"string","key":true}'

  it 'only accepts booleans for key' do
    expect {
      Datafile::ColumnDef.new(name: "c1", type: "string", key: "true")
    }.to raise_error("Key must be either true or false")
  end

  it 'can generate a hash' do
    cd = Datafile::ColumnDef.new(test_hash)
    expect(cd.to_hash).to eq(test_hash)
  end

  it 'can marshall JSON' do
    cd = Datafile::ColumnDef.new(test_hash)
    expect(cd.to_json).to eq(test_json)
  end

  it 'can unmarshall JSON' do
    cd = Datafile::ColumnDef.from_json(test_json)
    expect(cd.to_hash).to eq(test_hash)
  end
end
