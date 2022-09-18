module ApiGenerator
  module Services
    class CreateModel < BaseCreate
      def call
        prepare_folders

        create_models
        create_models_specs
      end

      private

      def prepare_folders
        create_dir(folders(:model_namespace_action))
        create_dir(folders(:spec_model))
      end

      def create_models
        models.each do |model|
          copy_template(templates(model), target_model(model), data.for_template)
        end
      end

      def create_models_specs
        specs.each do |template|
          copy_template(templates(template), target_spec(template), data.for_template)
        end
      end

      def models
        %i[request response]
      end

      def specs
        %i[request_spec response_spec]
      end

      def target_spec(template)
        File.expand_path("./#{template}.rb", folders(:spec_model))
      end

      def target_model(template)
        File.expand_path("./#{template}.erb", folders(:model_namespace_action))
      end

      def target_folders
        {
          model: "./lib/#{data.app_short_name}/model",
          model_namespace: "./lib/#{data.app_short_name}/model/#{data.namespace}",
          model_namespace_action:
            "./lib/#{data.app_short_name}/model/#{data.namespace}/#{data.action}",
          spec: './spec',
          spec_model: "./spec/model/#{data.namespace}/#{data.action}",
        }
      end

      def templates_files
        {
          request: './models/request.erb',
          response: './models/response.erb',
          responses: './models/responses.erb',
          paginated_response: './models/paginated_response.erb',
          request_spec: './specs/request_spec.erb',
          response_spec: './specs/response_spec.erb',
        }
      end
    end
  end
end
