module ApiGenerator
  module Models
    class Data < Base
      property :namespace
      property :action
      property :http_method
      property :paginate
      property :app_name
      property :app_short_name

      def for_template
        binding
      end
    end
  end
end
