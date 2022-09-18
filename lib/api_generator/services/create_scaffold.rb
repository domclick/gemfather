module ApiGenerator
  module Services
    class CreateScaffold
      attr_accessor :namespace, :action, :http_method, :paginate

      # rubocop:disable Style/OptionalBooleanParameter
      def initialize(namespace, action, http_method, paginate = false, root = nil)
        @namespace = namespace
        @action = action
        @http_method = http_method
        @paginate = paginate
        @root = root || File.expand_path(Dir.pwd)
      end
      # rubocop:enable Style/OptionalBooleanParameter

      def call
        create_api_w_specs
        create_models_w_specs
      end

      private

      def create_api_w_specs
        Services::CreateApi.new(@root, data).call
      end

      def create_models_w_specs
        Services::CreateModel.new(@root, data).call
      end

      def data
        Models::Data.new(
          namespace: namespace,
          action: action,
          http_method: http_method,
          paginate: paginate,
          app_name: app_name,
          app_short_name: app_name,
        )
      end

      def app_name
        @app_name ||= begin
          gemspec = Dir[File.expand_path('./*', @root)].grep(/\.gemspec/).first

          raise 'Not root of the API gem' unless gemspec

          File.basename(gemspec, '.gemspec')
        end
      end
    end
  end
end
