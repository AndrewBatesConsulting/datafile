require 'spec_helper'

describe Datafile::Conversions do
  it 'can convert booleans in various formats to TrueClass or FalseClass' do
    [
      ["0", false],
      ["1", true],
      ["false", false],
      ["true", true],
      ["FALSE", false],
      ["TRUE", true],
    ].each do |test|
      expect(Datafile::Conversions.convert(test[0]).to_bool).to eq(test[1])
    end
  end

  it 'can convert strings in various formats to datetimes' do
    # Time.new(2002, 10, 31, 2, 2, 2, "+02:00") #=> 2002-10-31 02:02:02 +0200
    [
      ["01/01/2000", Time.new(2000, 1, 1, 0, 0, 0)],
      ["01/01/99 01:01", Time.new(1999, 1, 1, 1, 1, 0)],
      ["01/01/2000 01:01", Time.new(2000, 1, 1, 1, 1, 0)],
      ["01/01/2000 01:01:01", Time.new(2000, 1, 1, 1, 1, 1)],
      ["01/01/99 01:01:01", Time.new(1999, 1, 1, 1, 1, 1)],
      ["2000-01-01 01:01:01", Time.new(2000, 1, 1, 1, 1, 1)],
    ].each do |test|
      expect(Datafile::Conversions.convert(test[0]).to_date).to eq(test[1])
    end
  end

  it 'can convert strings into integers' do
    expect(Datafile::Conversions.convert("1234").to_int).to eq(1234)
  end

  it 'can convert to a specified type' do
    expect(Datafile::Conversions.convert("true").to("bool")).to eq(true)
    expect(Datafile::Conversions.convert("01/01/2000").to("date")).to eq(Time.new(2000, 1, 1, 0, 0, 0))
    expect(Datafile::Conversions.convert("1234").to("int")).to eq(1234)
  end
end
