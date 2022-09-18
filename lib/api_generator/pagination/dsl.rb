module ApiGenerator::Pagination
  module Dsl
    STRATEGIES = {
      limit_offset: LimitOffsetRelation,
      page: PageRelation,
    }.freeze

    # rubocop:disable Metrics/MethodLength
    # @param [Array<Symbol] methods список методов для применения пагинации
    # @param [Symbol, Class] with стратегия пагинации (например, :limit_offset, :page)
    # @param data_key ключ, по которому можно получить массив данных в ответе
    # @param [Proc] on_request
    #   коллбэк, вызываемый при запросе и принимающий как аргументы запрос и параметры
    # @param [Hash] config дополнительная конфигурация для стратегии пагинации
    def paginate(*methods, with:, data_key:, on_request:, **config)
      relation_class = STRATEGIES.fetch(with, with)

      prepend(
        Module.new do
          methods.each do |method|
            define_method(method) do |*args|
              relation_class.new(config.merge(data_key: data_key)) do |relation|
                super(*args) { |req| on_request.call(req, **relation.request_options) }
              end
            end
          end
        end,
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end
