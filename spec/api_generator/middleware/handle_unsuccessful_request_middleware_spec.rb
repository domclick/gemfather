require 'spec_helper'

RSpec.describe ApiGenerator::Middleware::HandleUnsuccessfulRequestMiddleware do
  context 'when success is false' do
    let(:middleware) { Class.new(described_class).new }
    let(:response) { { 'success' => false } }
    let(:env) do
      instance_double(
        Faraday::Env,
        body: response,
        request_body: '',
        request_headers: {},
        response_headers: {},
      )
    end

    it 'raises error' do
      expect { middleware.on_complete(env) }.to(
        raise_error(ApiGenerator::Middleware::HttpErrors::UnsuccessfulRequestError),
      )
    end
  end
end
