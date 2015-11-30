require 'spec_helper'

describe Datafile::ColumnDef do
  test_hash = {
    name: "c1",
    type: "string",
  }

  test_json = '{"name":"c1","type":"string"}'

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
