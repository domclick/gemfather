class ApiGenerator::Pagination::LimitOffsetRelation < ApiGenerator::Pagination::Relation
  def limit(limit)
    expand(limit: limit)
  end

  def offset(offset)
    expand(offset: offset)
  end

  private

  def next_relation
    limit = config[:limit]&.call(response) || size
    offset = config[:offset]&.call(response) || options[:offset].to_i

    expand(offset: offset + limit)
  end

  def last_page?
    return size < config[:limit].call(response) if config[:limit]

    data.empty?
  end
end
