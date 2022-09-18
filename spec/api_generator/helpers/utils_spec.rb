require 'spec_helper'

RSpec.describe ApiGenerator::Helpers::Utils do
  let(:utils) do
    klass = Class.new
    klass.class_exec(described_class) { |mod| include mod }
    klass.new
  end

  let(:insert) { 'Insert' }

  let(:content) do
    <<~CONTENT.chomp
      Unindented
        MARKER
      Unindented
    CONTENT
  end

  let(:expected) do
    <<~EXPECTED.chomp
      Unindented
        MARKER
        Insert
      Unindented
    EXPECTED
  end

  it 'injects indented text' do
    result = utils.inject_after(content, 'MARKER', insert)

    expect(result).to eq(expected)
  end
end
