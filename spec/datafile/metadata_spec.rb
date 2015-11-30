require 'spec_helper'

describe Datafile::Metadata do
  before :each do
    @test_hash = {
      columns: {
        "c1" => {
          name: "c1",
          type: "string",
        },
        "c2" => {
          name: "c2",
          type: "string",
        }
      }
    }

    @test_json = '{"columns":{"c1":{"name":"c1","type":"string"},"c2":{"name":"c2","type":"string"}}}'
  end

  it 'can marshal JSON' do
    m = Datafile::Metadata.new()
    m << Datafile::ColumnDef.new(name: "c1", type: "string")
    m << Datafile::ColumnDef.new(name: "c2", type: "string")
    expect(m.to_json).to eq(@test_json)
  end

  it 'can unmarshal JSON' do
    m = Datafile::Metadata.from_json(@test_json)
    expect(m.to_hash).to eq(@test_hash)
  end
end
