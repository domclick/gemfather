module ApiGenerator
  module Client
    module Config
      class ConfigurationError < StandardError; end

      USER_AGENT = 'Ruby API Client'.freeze
      OPEN_TIMEOUT = 3
      READ_TIMEOUT = 3
      MAX_RETRIES = 3
      RETRY_INTERVAL = 1
      RETRY_BACKOFF_FACTOR = 1
      CONNECTION_ERROR = ApiGenerator::Middleware::HttpErrors::ConnectionError

      # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      def self.extended(klass)
        klass.extend Dry::Configurable

        klass.class_eval do
          setting :api_endpoint, reader: true
          setting :user_agent, default: USER_AGENT, reader: true

          setting :api_header, reader: true
          setting :api_token, reader: true

          setting :api_user, reader: true
          setting :api_password, reader: true

          setting :ssl_verify, reader: true
          setting :ca_file, reader: true

          setting :open_timeout, default: OPEN_TIMEOUT, reader: true
          setting :read_timeout, default: READ_TIMEOUT, reader: true
          setting :max_retries, default: MAX_RETRIES, reader: true
          setting :retry_interval, default: RETRY_INTERVAL, reader: true
          setting :retry_backoff_factor, default: RETRY_BACKOFF_FACTOR, reader: true
          setting :logger, reader: true
          setting :enable_instrumentation, reader: true

          setting :retriable_errors, default: [CONNECTION_ERROR], reader: true
        end
      end
      # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

      def check_config
        raise ConfigurationError, 'API endpoint is not configured.' if config.api_endpoint.nil?
      end

      def inherit_config!(other_config)
        config.to_h.each_key { |setting| config[setting] = other_config[setting] }
        config
      end

      def same_config?(other_config)
        config.to_h == other_config.to_h
      end
    end
  end
end
