class ApiGenerator::Pagination::Relation
  include Enumerable

  attr_reader :options

  def initialize(config, options = {}, &fetch_block)
    @config = config
    @options = options
    @fetch_block = fetch_block
  end

  # Получение всех записей начиная с текущей страницы (страницы грузятся по мере необходимости,
  # и элементы передаются в enumerator)
  def all_remaining
    expand(all_remaining: true)
  end

  def order(sort)
    expand(sort: sort)
  end

  # @return [Enumerator, ApiGenerator::Pagination::Relation] Enumerator по всем элементам,
  # Если задана опция all_remaining, клиент посылает запросы за следующими страницами
  # по мере необходимости, иначе загружаются только элементы текущей страницы
  def each(&block)
    return to_enum(:each) unless block

    data.each(&block)

    return self if !all_remaining? || last_page?

    next_relation.each(&block)
  end

  # Возвращает ответ в исходном виде
  def response
    @response ||= fetch_block.call(self)
  end

  # @return [Integer] количество элементов на текущей странице
  def size
    data.size
  end

  # @return [Integer] общее количество элементов на всех страницах
  # @raise [NotImplementedError] в случае, если коллбэк `total` не задан в конфиге DSL
  def total
    raise NotImplementedError, 'Total callback is not set in configuration' if config[:total].blank?

    config[:total]&.call(response)
  end
  alias total_count total

  # @return [Integer] общее количество элементов на всех страницах (сначала загрузит все страницы)
  def total!
    total
  rescue NotImplementedError
    self.class.new(config, {}, &fetch_block).all_remaining.count
  end
  alias total_count! total!

  alias all to_a

  def inspect
    class_name_with_status = [self.class, ('(not fetched)' if @response.blank?)].compact.join(' ')

    "#<#{class_name_with_status} #{options}>"
  end

  alias to_s inspect

  def pretty_print(pretty_printer)
    pretty_printer.text(inspect)
  end

  def request_options
    options.except(:all_remaining)
  end

  private

  attr_reader :fetch_block, :config

  def data
    case data_key
    when Symbol, String
      response.public_send(data_key)
    when Array
      response.dig(*data_key)
    else
      raise ArgumentError, 'Data key should be a symbol, string or array'
    end
  end

  def expand(**options)
    self.class.new(config, self.options.merge(options), &fetch_block)
  end

  def data_key
    config[:data_key] || :itself
  end

  def all_remaining?
    options[:all_remaining]
  end

  def next_relation
    raise NotImplementedError
  end

  def last_page?
    raise NotImplementedError
  end
end
