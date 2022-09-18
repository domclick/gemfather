module ApiGenerator
  module Middleware
    class RaiseErrorBase < Faraday::Response::Middleware
      private

      def message(env)
        "Server returned #{env.status}: #{env.body}. Headers: #{env.response_headers.inspect}"
      end
    end
  end
end
