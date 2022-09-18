require 'spec_helper'

module ClientParent
  module HttpErrors
    class BaseError < StandardError
      attr_reader :body

      def initialize(msg = nil, body = nil)
        @body = body if body
        super(msg)
      end
    end

    class ServerError < BaseError; end
    class ClientError < BaseError; end
    class UnsuccessfulRequestError < ClientError; end
  end

  class Client < ApiGenerator::Client::Connection
    on_status 401, error: :unauthorized_error
  end
end

RSpec.describe ApiGenerator::Client::Connection do
  let(:client_class) { Class.new(described_class) }
  let(:client) { client_class.new }
  let(:interval) { 0.01 }
  let(:retries) { 5 }

  before do
    client_class.reset_config

    client_class.configure do |config|
      config.api_endpoint = 'http://web.mock'
      config.retry_interval = interval
      config.max_retries = retries
    end
  end

  context 'when set token and header' do
    let(:client) do
      client_class.new(
        api_token: 'TOKEN',
        api_header: 'X-Source-Token',
      )
    end

    it 'uses token auth' do
      expect(client.headers['X-Source-Token']).to eq('TOKEN')
    end
  end

  context 'when set login and password' do
    let(:login_client) do
      client_class.new(
        api_user: 'user',
        api_password: 'pass',
      )
    end

    it 'uses basic auth' do
      stub_request(:post, 'http://web.mock/basic_auth')
        .with(basic_auth: %w[user pass])
        .to_return(status: 200)

      response = login_client.post('/basic_auth')
      expect(response.status).to eq(200)
    end
  end

  context 'when passed customizing block' do
    let(:custom_client) do
      client_class.new do |connection|
        connection.headers['Custom-Header'] = 'value'
      end
    end

    it 'processes connection' do
      stub_request(:get, 'http://web.mock/custom')
        .with(headers: { 'Custom-Header' => 'value' })
      response = custom_client.get('/custom')

      expect(response.status).to eq(200)
    end
  end

  context 'when added error handling' do
    let(:api_class) { client_class }
    let(:client) { client_class.new }

    before do
      api_class.class_eval do
        on_status 400, error: :invalid_request_error
        on_status 401, error: :unauthorized_error
        on_status 503, error: :everything_fucked_up_error
      end
    end

    it 'raises error at status 400' do
      stub_request(:get, 'http://web.mock/error_400')
        .to_return(status: 400)

      expect { client.get('/error_400') }
        .to(raise_error(ApiGenerator::Middleware::HttpErrors::InvalidRequestError))
      expect { client.get('/error_400') }
        .to(raise_error(ApiGenerator::Middleware::HttpErrors::ClientError))
    end

    it 'raises error at status 401' do
      stub_request(:get, 'http://web.mock/error_401')
        .to_return(status: 401)

      expect { client.get('/error_401') }
        .to(raise_error(ApiGenerator::Middleware::HttpErrors::UnauthorizedError))
    end

    context 'when error code is 500+' do
      subject(:request) { client.get('/error_503') }

      before do
        stub_request(:get, 'http://web.mock/error_503')
          .to_return(status: 503)
      end

      it 'raises child of ServerError' do
        expect { request }
          .to raise_error(ApiGenerator::Middleware::HttpErrors::EverythingFuckedUpError)
        expect { request }.to raise_error(ApiGenerator::Middleware::HttpErrors::ServerError)
      end

      context 'when error code is not configured explicitly' do
        subject(:request) { client.get('/error_504') }

        before do
          stub_request(:get, 'http://web.mock/error_504')
            .to_return(status: 504)
        end

        it 'raises ServerError' do
          expect { request }.to raise_error(ApiGenerator::Middleware::HttpErrors::ServerError)
        end
      end
    end

    context 'when client has its own error namespace' do
      before do
        stub_request(:get, 'http://web.mock/error_401')
          .to_return(status: 401)
      end

      let(:client_class) { ClientParent::Client }

      it 'raises custom error' do
        expect { ClientParent::Client.new.get('/error_401') }
          .to(raise_error(ClientParent::HttpErrors::UnauthorizedError))
      end

      context 'when error code is not configured explicitly' do
        subject(:request) { client.get('/error_403') }

        before do
          stub_request(:get, 'http://web.mock/error_403')
            .to_return(status: 403)
        end

        it 'raises ClientError' do
          expect { request }.to raise_error(ClientParent::HttpErrors::ClientError)
        end
      end
    end
  end

  context 'when response is not success' do
    before do
      stub_request(:post, 'http://web.mock/success_false')
        .to_return(body: { success: false }.to_json)
    end

    it 'fails with error' do
      expect { client.post('/success_false') }
        .to(raise_error(ApiGenerator::Middleware::HttpErrors::UnsuccessfulRequestError))
    end

    context 'when client has its own error namespace' do
      let(:client_class) { ClientParent::Client }

      it 'fails with custom error' do
        expect { client.post('/success_false') }
          .to(raise_error(ClientParent::HttpErrors::UnsuccessfulRequestError))
      end
    end
  end

  it 'is aimed at correct url' do
    expect(client.url_prefix).to eq(URI('http://web.mock'))
  end

  it 'can make a request' do
    expect(client).to respond_to(:get)
    expect(client).to respond_to(:post)
    expect(client).to respond_to(:patch)
    expect(client).to respond_to(:put)
  end

  it 'has middleware' do
    expect(client.builder.handlers).to include(client.class::ErrorHandlerMiddleware)
  end

  it 'raises error at timeout' do
    stub_request(:get, 'http://web.mock/timeout')
      .to_timeout

    expect { client.get('/timeout') }
      .to(raise_error(ApiGenerator::Middleware::HttpErrors::ConnectionError))

    expect(a_request(:get, 'http://web.mock/timeout')).to have_been_made.times(retries + 1)
  end

  it 'raises error at connection_failed' do
    stub_request(:get, 'http://web.mock/connection_failed')
      .to_raise(Faraday::ConnectionFailed)

    expect { client.get('/connection_failed') }
      .to(raise_error(ApiGenerator::Middleware::HttpErrors::ConnectionError))
  end

  it 'raises error at ssl_error' do
    stub_request(:get, 'http://web.mock/ssl_error')
      .to_raise(Faraday::SSLError)

    expect { client.get('/ssl_error') }
      .to(raise_error(ApiGenerator::Middleware::HttpErrors::ConnectionError))
  end
end
