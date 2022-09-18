module ApiGenerator
  module Services
    class CreateApi < BaseCreate
      PATH_MARKER = 'PATHS'.freeze
      ACTION_MARKER = 'ACTIONS'.freeze
      INCLUDE_MARKER = 'INCLUDES'.freeze

      def call
        prepare_folders

        create_api_module
        add_path
        add_action
        add_module_to_client

        create_api_spec
      end

      private

      def prepare_folders
        create_dir(folders(:api))
        create_dir(folders(:spec_api))
      end

      def create_api_module
        return if File.exist?(api_module)

        copy_template(templates(:api_module), api_module, data.for_template)
      end

      def add_path
        inject_after_str(api_module, PATH_MARKER, render_template(:path))
      end

      def add_action
        if data.paginate
          inject_after_str(api_module, INCLUDE_MARKER, render_template(:include_helpers))
          inject_after_str(api_module, ACTION_MARKER, render_template(:action_paginate))
        else
          inject_after_str(api_module, ACTION_MARKER, render_template(:action))
        end
      end

      def add_module_to_client
        inject_after_str(client_class, INCLUDE_MARKER, render_template(:include_namespace))
      end

      def create_api_spec
        copy_template(templates(:api_spec), api_spec, data.for_template)
      end

      def api_module
        File.expand_path("./#{data.namespace}.rb", folders(:api))
      end

      def client_class
        File.expand_path('./client.rb', folders(:app))
      end

      def api_spec
        File.expand_path("./#{data.namespace}_spec.rb", folders(:spec_api))
      end

      def templates_files
        {
          api_module: './api/api_module.erb',
          path: './api/path.erb',
          action: './api/action.erb',
          action_paginate: './api/action_paginate.erb',
          include_helpers: './api/include_helpers.erb',
          include_namespace: './api/include_namespace.erb',
          api_spec: './specs/api_spec.erb',
        }
      end

      def target_folders
        {
          app: "./lib/#{data.app_short_name}",
          api: "./lib/#{data.app_short_name}/api",
          spec: './spec',
          spec_api: './spec/api',
        }
      end
    end
  end
end
