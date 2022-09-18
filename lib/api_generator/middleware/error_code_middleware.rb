module ApiGenerator
  module Middleware
    class ErrorCodeMiddleware < Faraday::Response::Middleware
      def self.inherited(subclass)
        class << subclass
          attr_accessor :error_mapping, :error_namespace

          def add_error(code, exception)
            error_mapping[code] = exception
          end
        end

        subclass.error_mapping ||= {}
        subclass.error_namespace ||= ApiGenerator::Middleware::HttpErrors

        super
      end

      def on_complete(env)
        error_class = error_class(env.status)
        return unless error_class

        raise(error_class.new(message(env), env.body))
      end

      private

      def message(env)
        "Server returned #{env.status}: #{env.body}. Headers: #{env.response_headers.inspect}"
      end

      def error_class(code)
        self.class.error_mapping.fetch(code) do
          if code >= 500
            self.class.error_namespace::ServerError
          elsif code >= 400
            self.class.error_namespace::ClientError
          end
        end
      end
    end
  end
end
