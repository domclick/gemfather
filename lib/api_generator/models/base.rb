module ApiGenerator
  module Models
    class Base < Hashie::Trash
      include Hashie::Extensions::Dash::Coercion
      include Hashie::Extensions::Dash::IndifferentAccess
      include Hashie::Extensions::IgnoreUndeclared

      def self.parse_time
        ->(time) { Time.parse(time) }
      end

      private_class_method :parse_time
    end
  end
end
