require 'spec_helper'

RSpec.describe ApiGenerator::Models::Base do
  let(:model_class) do
    Class.new(described_class) do
      property :declared
      property :coerce_to_integer, coerce: Integer
      property :time, transform_with: parse_time
    end
  end

  let(:model) do
    model_class.new(
      declared: true,
      coerce_to_integer: '1',
      time: '2012-12-25',
      undeclared: 'UNDECLARED',
    )
  end

  it 'coerce' do
    expect(model.coerce_to_integer).to eq(1)
  end

  it 'ignore undeclared' do
    expect { model['undeclared'] }.to raise_error NoMethodError
  end

  it 'indifferent access' do
    expect(model['declared']).to be(true)
  end

  it 'parses time' do
    expect(model.time).to eq(Time.new(2012, 12, 25))
  end
end
