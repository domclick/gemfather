module ApiGenerator
  module Services
    class Gemfather < Thor
      include Thor::Actions

      # octal notation for rubocop
      EXEC_MODE = 0o0755

      cattr_accessor :target_dir
      attr_accessor :app_name, :app_name_class, :app_short_name,
                    :app_short_name_class, :author, :email, :version

      def self.source_root
        File.expand_path('./../../../', __dir__)
      end

      # rubocop:disable Metrics/MethodLength
      desc 'generates API gem', 'generates basic API gem with the provided name'
      def generate_client(app_name)
        check_app_name(app_name)
        setup_template_variables(app_name)

        check_if_folder_exists

        directory(template_path, destination_path, { context: binding })

        inside(destination_path) do
          empty_directory('log')
          run('bundle')
          run('bundle binstubs rspec-core rubocop --force')
          run('git init')
          set_executables
        end
      end
      # rubocop:enable Metrics/MethodLength

      private

      def check_app_name(app_name)
        raise(Thor::Error, 'APP_NAME is not provided') unless app_name
        raise(Thor::Error, "Folder #{app_name} name already exists") if Dir.exist?("./#{app_name}")
        raise(Thor::Error, "Api name can start only with letter or _") if app_name.chr.match(/[a-zA-Z_]/).nil?
      end

      def setup_template_variables(app_name)
        self.app_name = app_name
        self.app_short_name = app_name
        self.app_name_class = app_short_name.camelize
        self.app_short_name_class = app_short_name.camelize
        self.author = 'Domclick Ruby Team'
        self.email = `git config user.email`
        self.version = ApiGenerator::VERSION
      end

      def check_if_folder_exists
        Dir.exist?(destination_path) &&
          (file_collision(destination_path) ||
            raise(Thor::Error, 'Directory already exists'))
      end

      def destination_path
        File.expand_path(app_name, called_from_path)
      end

      def called_from_path
        self.class.target_dir || Dir.pwd
      end

      def template_path
        File.expand_path('./gem_template', self.class.source_root)
      end

      def set_executables
        Dir[File.expand_path('./*', 'bin')].each do |file|
          chmod(file, EXEC_MODE)
        end
      end
    end
  end
end
