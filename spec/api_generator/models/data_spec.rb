require 'spec_helper'

RSpec.describe ApiGenerator::Models::Data do
  let(:model) { described_class.new }

  it 'converts to binding' do
    expect(model).to respond_to(:for_template)
    expect(model.for_template).to be_an_instance_of(Binding)
  end
end
