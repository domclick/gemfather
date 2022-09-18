require 'spec_helper'

RSpec.describe ApiGenerator::Client::Config do
  let(:klass) { Class.new.instance_exec(described_class) { |klass| extend klass } }

  it 'all params are configured' do
    expect(klass.api_endpoint).to be_nil
    expect(klass.api_token).to be_nil
    expect(klass.logger).to be_nil
    expect(klass.user_agent).to eq('Ruby API Client')
    expect(klass.open_timeout).to eq(3)
    expect(klass.read_timeout).to eq(3)
    expect(klass.max_retries).to eq(3)
    expect(klass.retry_interval).to eq(1)
    expect(klass.retry_backoff_factor).to eq(1)
    expect(klass.retriable_errors).to eq([ApiGenerator::Middleware::HttpErrors::ConnectionError])
  end

  it 'is configurable' do
    expect(klass).to respond_to(:configure)
  end
end
