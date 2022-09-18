require 'spec_helper'

RSpec.describe ApiGenerator::Pagination::LimitOffsetRelation do
  let(:relation) { described_class.new(config, options, &fetch_block) }
  let(:config) { {} }
  let(:options) { {} }
  let(:fetch_block) { -> {} }

  describe '#limit' do
    subject(:new_relation) { relation.limit(limit) }

    let(:limit) { rand(100) }
    let(:offset) { rand(100) }
    let(:options) { { offset: offset } }

    it 'instantiates a forked relation with a new limit' do
      expect(new_relation.options).to eq({ limit: limit, offset: offset })
      expect(new_relation.object_id).not_to eq(relation.object_id)
    end
  end

  describe '#offset' do
    subject(:new_relation) { relation.offset(offset) }

    let(:limit) { rand(100) }
    let(:offset) { rand(100) }
    let(:options) { { limit: limit } }

    it 'instantiates a forked relation with a new offset' do
      expect(new_relation.options).to eq({ limit: limit, offset: offset })
      expect(new_relation.object_id).not_to eq(relation.object_id)
    end
  end

  describe 'enumerable implementation' do
    let(:config) { { data_key: :numbers, limit: :limit.to_proc, offset: :offset.to_proc } }
    let(:page_1_numbers) { Array.new(10) { rand(100) } }
    let(:page_2_numbers) { Array.new(9) { rand(100) } }
    let(:offset) { 0 }
    let(:limit) { 10 }
    let(:options) { { limit: limit, offset: offset } }
    let(:block_calls) { Struct.new(:counter).new(0) }
    let(:total) { 100 }

    let(:fetch_block) do
      lambda do |relation|
        block_calls.counter += 1
        Struct.new(:numbers, :limit, :offset, :total).new(
          *(
            if relation.options[:offset].to_i.zero?
              [page_1_numbers, limit, offset]
            elsif relation.options[:offset] == 10
              [page_2_numbers, limit, offset + limit]
            else
              [[], limit, offset + (limit * 2)]
            end
          ),
          total,
        )
      end
    end

    it 'fetches first page elements' do
      expect(relation.to_a).to eq(page_1_numbers)
      expect(block_calls.counter).to eq(1)
    end

    context 'with all_remaining scope' do
      let(:relation) { super().all_remaining }

      it 'fetches all elements' do
        expect(relation.to_a).to eq([*page_1_numbers, *page_2_numbers])
        expect(block_calls.counter).to eq(2)
      end

      context 'when meta data is unknown' do
        let(:config) { { data_key: :numbers } }

        it 'still fetches all elements' do
          expect(relation.to_a).to eq([*page_1_numbers, *page_2_numbers])
          expect(block_calls.counter).to eq(3)
        end
      end
    end

    context 'with custom offset' do
      let(:offset) { 10 }

      it 'fetches only the second page' do
        expect(relation.to_a).to eq page_2_numbers
        expect(block_calls.counter).to eq(1)
      end
    end

    describe '#total' do
      subject(:total_result) { relation.total }

      let(:config) { { total: :total.to_proc } }

      it 'returns total' do
        expect(total_result).to eq(total)
      end

      context 'when total callback is not set in config' do
        let(:config) { { data_key: :numbers } }

        it 'raises error' do
          expect { total_result }.to raise_error(NotImplementedError)
        end
      end
    end

    describe '#total!' do
      subject(:total_result) { relation.offset(10).total! }

      let(:config) { { total: :total.to_proc } }

      it 'returns total' do
        expect(total_result).to eq(total)
      end

      context 'when total callback is not set in config' do
        let(:config) { { data_key: :numbers } }

        it 'counts all elements and returns total' do
          expect(total_result).to eq(page_1_numbers.size + page_2_numbers.size)
        end
      end
    end
  end
end
