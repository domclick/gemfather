module ApiGenerator
  module Railtie
    # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
    def self.extended(klass)
      return unless defined?(Rails)

      klass.class_eval do |target_class|
        initializer_name = "#{target_class.to_s.deconstantize.underscore}.configure"
        initializer initializer_name, after: 'initialize_logger' do
          target_class.name.deconstantize.constantize::Client.configure do |config|
            config.user_agent = [
              Rails.application.class.module_parent_name.underscore,
              Rails.env,
              config.user_agent,
            ].join(' - ')

            config.logger = Rails.logger if Rails.env.development? || Rails.env.test?
          end
        end
      end
    end
    # rubocop:enable Metrics/MethodLength,Metrics/AbcSize
  end
end
