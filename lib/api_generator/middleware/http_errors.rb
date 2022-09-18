module ApiGenerator
  module Middleware
    module HttpErrors
      class ConnectionError < StandardError; end

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
  end
end
