require 'spec_helper'

RSpec.describe ApiGenerator::Pagination::PageRelation do
  let(:relation) { described_class.new(config, options, &fetch_block) }
  let(:config) { {} }
  let(:options) { {} }
  let(:fetch_block) { -> {} }

  describe '#page' do
    subject(:new_relation) { relation.page(page) }

    let(:page) { rand(100) }
    let(:per_page) { rand(100) }
    let(:options) { { per_page: per_page } }

    it 'instantiates a forked relation with a new page' do
      expect(new_relation.options).to eq({ page: page, per_page: per_page })
      expect(new_relation.object_id).not_to eq(relation.object_id)
    end
  end

  describe '#per' do
    subject(:new_relation) { relation.per(per_page) }

    let(:page) { rand(100) }
    let(:per_page) { rand(100) }
    let(:options) { { page: page } }

    it 'instantiates a forked relation with a new per_page' do
      expect(new_relation.options).to eq({ page: page, per_page: per_page })
      expect(new_relation.object_id).not_to eq(relation.object_id)
    end
  end

  describe 'enumerable implementation' do
    let(:config) { { data_key: :numbers, per_page: :per_page.to_proc, page: :page.to_proc } }
    let(:page_1_numbers) { Array.new(10) { rand(100) } }
    let(:page_2_numbers) { Array.new(9) { rand(100) } }
    let(:page) { 1 }
    let(:per_page) { 10 }
    let(:options) { { per_page: per_page, page: page } }
    let(:block_calls) { Struct.new(:counter).new(0) }
    let(:total) { 100 }

    let(:fetch_block) do
      lambda do |relation|
        block_calls.counter += 1
        Struct.new(:numbers, :per_page, :page, :total).new(
          *(
            case relation.options[:page]
            when 1, nil
              [page_1_numbers, per_page, page]
            when 2
              [page_2_numbers, per_page, page + 1]
            else
              [[], per_page, page + 2]
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

    context 'with custom page' do
      let(:page) { 2 }

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
      subject(:total_result) { relation.page(2).total! }

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
