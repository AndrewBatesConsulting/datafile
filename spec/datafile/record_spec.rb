require 'spec_helper'

describe Datafile::Record do
  it 'can unmarshal a hash' do
    r = Datafile::Record.from_row("c1" => "v1", "c2" => "v2", "c3" => "v3")
    expect(r["c1"]).to eq("v1")
    expect(r["c2"]).to eq("v2")
    expect(r["c3"]).to eq("v3")
  end
end
