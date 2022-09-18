require 'spec_helper'

RSpec.describe ApiGenerator::Pagination::Dsl do
  describe '.paginate' do
    let(:request) { Struct.new(:params).new({}) }
    let(:response) { Struct.new(:numbers, :limit, :offset).new(numbers, limit, offset) }
    let(:numbers) { Array.new(5) { rand(100) } }
    let(:limit) { rand(10) }
    let(:offset) { rand(10) }

    let(:client_class) do
      request = self.request
      response = self.response

      Class.new do
        extend ApiGenerator::Pagination::Dsl

        define_method :find_numbers do |&block|
          block.call(request)
          response
        end
      end
    end

    context 'when limit/offset strategy is chosen' do
      subject(:find_numbers) { client_class.new.find_numbers }

      before do
        client_class.paginate :find_numbers,
                              with: :limit_offset,
                              data_key: :numbers,
                              on_request: lambda { |req, limit: nil, offset: nil|
                                req.params[:limit] = limit if limit.present?
                                req.params[:offset] = offset if offset.present?
                              },
                              limit: :limit.to_proc,
                              offset: :offset.to_proc
      end

      it 'wraps client method' do
        relation = find_numbers.limit(limit).offset(offset)
        expect(relation).to be_instance_of ApiGenerator::Pagination::LimitOffsetRelation
        expect(relation.size).to eq 5
        expect(request.params).to eq({ limit: limit, offset: offset })
      end
    end
  end
end
