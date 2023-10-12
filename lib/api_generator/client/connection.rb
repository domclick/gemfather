module ApiGenerator
  module Client
    # rubocop:disable Metrics/ClassLength
    class Connection < SimpleDelegator
      extend Config

      class << self
        def inherited(subclass)
          subclass.extend Middleware::RaiseErrorDsl

          error_namespace = begin
            subclass.module_parent::HttpErrors
          rescue NameError
            ApiGenerator::Middleware::HttpErrors
          end

          subclass.setup_middleware(error_namespace)

          super
        end

        def setup_middleware(error_namespace)
          unsuccessful_request_middleware = Class.new(
            Middleware::HandleUnsuccessfulRequestMiddleware,
          )
          unsuccessful_request_middleware.error_namespace = error_namespace if error_namespace
          const_set(:HandleUnsuccessfulRequestMiddleware, unsuccessful_request_middleware)

          error_handler_middleware = Class.new(Middleware::ErrorHandlerMiddleware)
          error_handler_middleware.error_namespace = error_namespace if error_namespace
          const_set(:ErrorHandlerMiddleware, error_handler_middleware)
        end
      end

      ACCEPT_HEADER = 'application/json'.freeze

      attr_accessor :customization_block

      def initialize(**settings, &blk)
        if instance_of?(Connection)
          raise LoadError, 'This class is abstract and is not intended to be initialized directly'
        end

        self.customization_block = blk if blk

        config = self.class.inherit_config!(self.class.config)
        settings.each { |setting, value| config[setting] = value }
        self.class.check_config

        super(connection)
      end

      private

      # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      def connection
        set_instrumentation_context

        @connection ||= Faraday.new(url: self.class.api_endpoint) do |connection|
          setup_auth!(connection)

          setup_failed_req_handling!(connection)
          setup_timeouts!(connection)
          setup_user_agent!(connection)
          setup_logger!(connection)
          setup_retries!(connection)
          setup_error_handling!(connection)
          setup_error_code_middleware!(connection)
          setup_ssl(connection)
          setup_instrumentation!(connection)

          customize_connection!(connection)

          # When set last - req/res parsed as json in middleware
          setup_json!(connection)

          connection.adapter(Faraday.default_adapter)
        end
      end
      # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

      # rubocop:disable Metrics/AbcSize
      def setup_auth!(connection)
        if self.class.api_token && self.class.api_header
          connection.headers[self.class.api_header] = self.class.api_token
        elsif self.class.api_user && self.class.api_password
          connection.use(
            Faraday::Request::BasicAuthentication,
            self.class.api_user,
            self.class.api_password,
          )
        end
      end
      # rubocop:enable Metrics/AbcSize

      def setup_json!(connection)
        connection.headers[:accept] = ACCEPT_HEADER
        connection.request(:json)
        connection.response(:json)
      end

      def setup_timeouts!(connection)
        connection.options.open_timeout = self.class.open_timeout
        connection.options.timeout = self.class.read_timeout
      end

      def setup_user_agent!(connection)
        connection.headers[:user_agent] = self.class.user_agent
      end

      def setup_logger!(connection)
        connection.response(:logger, self.class.logger) if self.class.logger
      end

      def setup_instrumentation!(connection)
        return unless self.class.enable_instrumentation

        connection.use ApiGenerator::Middleware::Instrumentation,
                       name: 'gemfather_api_client.requests'
      end

      def set_instrumentation_context
        return unless self.class.enable_instrumentation

        action = caller_locations(4, 1)&.first&.label || 'unparsed_method'

        Thread.current[:gemfather_api_client] = {
          name: self.class.to_s,
          action: action,
        }
      end

      def setup_ssl(connection)
        connection.ssl.verify = self.class.ssl_verify
        connection.ssl.ca_file = self.class.ca_file
      end

      def setup_retries!(connection)
        return if self.class.max_retries <= 0

        connection.request(
          :retry,
          max: self.class.max_retries,
          interval: self.class.retry_interval,
          backoff_factor: self.class.retry_backoff_factor,
          exceptions: self.class.retriable_errors,
        )
      end

      def setup_failed_req_handling!(connection)
        connection.use(self.class::HandleUnsuccessfulRequestMiddleware)
      end

      def setup_error_handling!(connection)
        connection.use(self.class::ErrorHandlerMiddleware)
      end

      def setup_error_code_middleware!(connection)
        connection.use(self.class::ErrorCodeMiddleware)
      end

      def customize_connection!(connection)
        return unless customization_block

        customization_block.call(connection)
      end
    end
    # rubocop:enable Metrics/ClassLength
  end
end
