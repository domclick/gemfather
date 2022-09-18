class ApiGenerator::Pagination::PageRelation < ApiGenerator::Pagination::Relation
  def page(page)
    expand(page: page)
  end

  def per(size)
    expand(per_page: size)
  end

  private

  def next_relation
    expand(page: [options[:page].to_i, 1].max + 1)
  end

  def last_page?
    return data.size < config[:per_page].call(response) if config[:per_page]

    data.empty?
  end
end
