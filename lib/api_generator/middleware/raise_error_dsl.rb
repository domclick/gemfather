module ApiGenerator
  module Middleware
    module RaiseErrorDsl
      def self.extended(klass)
        klass.singleton_class.class_eval { attr_accessor :error_namespace }
        klass.error_namespace ||= if klass.module_parent.const_defined?(:HttpErrors)
                                    klass.module_parent::HttpErrors
                                  else
                                    ApiGenerator::Middleware::HttpErrors
                                  end
        error_code_middleware = Class.new(ErrorCodeMiddleware)
        error_code_middleware.error_namespace = klass.error_namespace
        klass.const_set(:ErrorCodeMiddleware, error_code_middleware)

        super
      end

      def on_status(code, error:)
        self::ErrorCodeMiddleware.add_error(code, error_const(code, error))
      end

      private

      def error_const(code, error_name)
        const_name = error_name.to_s.camelize

        return error_namespace.const_get(const_name) if error_namespace.const_defined?(const_name)

        error_namespace.const_set(
          const_name,
          Class.new(code >= 500 ? error_namespace::ServerError : error_namespace::ClientError),
        )
      end
    end
  end
end
