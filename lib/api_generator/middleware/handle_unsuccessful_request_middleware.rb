module ApiGenerator
  module Middleware
    class HandleUnsuccessfulRequestMiddleware < Faraday::Response::Middleware
      def self.inherited(subclass)
        class << subclass
          attr_accessor :error_namespace
        end

        subclass.error_namespace ||= ApiGenerator::Middleware::HttpErrors
        super
      end

      def on_complete(env)
        response_body = env.body

        return unless response_body.is_a?(Hash) && response_body['success'] == false

        raise(
          self.class.error_namespace::UnsuccessfulRequestError.new(
            message(env), env.body,
          ),
        )
      end

      private

      def message(env)
        <<~MSG
          Server is unable to process the request: #{env.request_body}.
          Headers: #{env.request_headers.inspect}
          Server returned: #{env.body}. Headers: #{env.response_headers.inspect}
        MSG
      end
    end
  end
end
