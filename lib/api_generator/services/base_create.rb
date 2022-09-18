module ApiGenerator
  module Services
    class BaseCreate
      include Helpers::Utils

      attr_reader :target, :data

      def initialize(target, data)
        @target = target
        @data = data
      end

      def call
        raise NotImplementedError
      end

      private

      def templates(name)
        File.expand_path(templates_files[name.to_sym], templates_folder)
      end

      def folders(name)
        File.expand_path(target_folders[name.to_sym], root)
      end

      def render_template(name)
        render(templates(name.to_sym), data.for_template)
      end

      def root
        target || File.expand_path(Dir.pwd)
      end

      def source_root
        gemfather_lib_path = $LOAD_PATH.grep(/gemfather/).first

        return File.expand_path('../', gemfather_lib_path) if gemfather_lib_path

        File.expand_path('../../../', __dir__)
      end

      def templates_folder
        File.expand_path('./templates', source_root)
      end

      def templates_files
        raise NotImplementedError
      end

      def target_folders
        raise NotImplementedError
      end
    end
  end
end
