require 'spec_helper'

RSpec.describe ApiGenerator::Services::CreateScaffold do
  let(:namespace) { 'deals' }
  let(:action) { 'create' }
  let(:http_method) { 'post' }
  let(:paginate) { true }
  let(:root) { nil }

  # rubocop:disable RSpec/AnyInstance
  it 'creates scaffold' do
    allow_any_instance_of(ApiGenerator::Services::CreateApi).to receive(:call)
    allow_any_instance_of(ApiGenerator::Services::CreateModel).to receive(:call)

    expect_any_instance_of(ApiGenerator::Services::CreateApi).to receive(:call)
    expect_any_instance_of(ApiGenerator::Services::CreateModel).to receive(:call)

    described_class.new(namespace, action, http_method, paginate, root).call
  end
  # rubocop:enable RSpec/AnyInstance
end
