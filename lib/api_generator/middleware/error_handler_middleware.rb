module ApiGenerator
  module Middleware
    class ErrorHandlerMiddleware < Faraday::Middleware
      FARADAY_CONNECTION_ERRORS = [
        Faraday::TimeoutError,
        Faraday::ConnectionFailed,
        Faraday::SSLError,
      ].freeze

      def self.inherited(subclass)
        class << subclass
          attr_accessor :error_namespace
        end

        subclass.error_namespace ||= ApiGenerator::Middleware::HttpErrors
        super
      end

      def call(env)
        @app.call(env)
      rescue *FARADAY_CONNECTION_ERRORS => e
        raise self.class.error_namespace::ConnectionError, e
      end
    end
  end
end
