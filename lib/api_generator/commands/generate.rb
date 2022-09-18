module ApiGenerator
  module Commands
    class Generate
      # rubocop:disable Layout/LineLength
      ARGS_REGEX = /(?<namespace>[\w\-_]+):(?<action>[\w\-_]+):(?<http_method>get|post|patch|put)/i.freeze
      # rubocop:enable Layout/LineLength

      def initialize(argv)
        @argv = argv[0..1]
      end

      def call
        service_args = [*parse_parameters(@argv), paginate(@argv)]

        shutdown unless service_args[0..2].all?(&:present?)

        Services::CreateScaffold.new(*service_args).call
      end

      private

      def usage
        <<~USAGE
          Generate API scaffold (api_namespace, models, specs)
          Usage: bin/generate NAMESPACE:ACTION:HTTP_METHOD [--paginate]
          Examples:
            bin/generate deals:search:post --paginate
            bin/generate persons:create:post
            bin/generate deals:update:put
        USAGE
      end

      def shutdown
        puts(usage) || exit
      end

      def parse_parameters(args)
        params = args.find { |arg| arg =~ ARGS_REGEX }

        shutdown unless params

        match_data = params.match(ARGS_REGEX)

        [
          match_data['namespace'],
          match_data['action'],
          match_data['http_method'],
        ]
      end

      def paginate(args)
        args.find { |arg| arg == '--paginate' }
      end
    end
  end
end
