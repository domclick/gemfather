module ApiGenerator
  module Middleware
    class Instrumentation < Faraday::Request::Instrumentation
      def call(env)
        env[:gemfather_api_client] = Thread.current[:gemfather_api_client]
        super(env)
      end
    end
  end
end
