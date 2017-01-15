require 'spec_helper'

module Observatory
  RSpec.describe Pagination do
    describe '::paginate' do
      context 'with a single-page range' do
        let(:result) { Pagination.paginate(1..1, 1) }

        it 'should contain three entries' do
          expect(result.count).to eq 3
        end

        it 'should contain disabled previous- and next- entries' do
          expect(result.first).to eq({ type: :prev, page: nil, attributes: [:disabled] })
          expect(result.last).to eq({ type: :next, page: nil, attributes: [:disabled] })
        end

        it 'should contain an active entry for page 1' do
          expect(result[1]).to eq({ type: :page, page: 1, attributes: [:active] })
        end
      end

      context 'with a range which is less than the maximum desired range' do
        let(:result) { Pagination.paginate(1..6, 2) }

        it 'should contain entries for all pages' do
          expected = [
            { type: :prev, page: 1, attributes: [] },

            { type: :page, page: 1, attributes: [] },
            { type: :page, page: 2, attributes: [:active] },
            { type: :page, page: 3, attributes: [] },
            { type: :page, page: 4, attributes: [] },
            { type: :page, page: 5, attributes: [] },
            { type: :page, page: 6, attributes: [] },

            { type: :next, page: 3, attributes: [] },
          ]

          expect(result).to eq expected
        end
      end

      context 'with a range which is equal to the maximum desired range' do
        let(:result) { Pagination.paginate(1..9, 5, leading: 3, surrounding: 1, trailing: 3) }

        it 'should contain entries for all pages' do
          expected = [
            { type: :prev, page: 4, attributes: [] },

            { type: :page, page: 1, attributes: [] },
            { type: :page, page: 2, attributes: [] },
            { type: :page, page: 3, attributes: [] },

            { type: :page, page: 4, attributes: [] },
            { type: :page, page: 5, attributes: [:active] },
            { type: :page, page: 6, attributes: [] },

            { type: :page, page: 7, attributes: [] },
            { type: :page, page: 8, attributes: [] },
            { type: :page, page: 9, attributes: [] },

            { type: :next, page: 6, attributes: [] },
          ]

          expect(result).to eq expected
        end
      end

      context 'with a range which is bigger than the maximum desired range' do
        let(:result) { Pagination.paginate(1..30, 11, leading: 3, surrounding: 3, trailing: 3) }
        # Expected:
        #   Prev: 10
        #   Pages: 1, 2, 3
        #   Separator
        #   Pages: 8, 9, 10, 11, 12, 13, 14
        #   Separator
        #   Pages: 28, 29, 30
        #   Next: 12

        it 'should contain entries for the leading pages' do
          expected = [
            { type: :page, page: 1, attributes: [] },
            { type: :page, page: 2, attributes: [] },
            { type: :page, page: 3, attributes: [] },
          ]

          # 0 is the 'prev page' link
          expect(result[1..3]).to eq expected
        end

        it 'should contain entries for the surrounding pages' do
          expected = [
            { type: :page, page: 8,  attributes: [] },
            { type: :page, page: 9,  attributes: [] },
            { type: :page, page: 10, attributes: [] },
            { type: :page, page: 11, attributes: [:active] },
            { type: :page, page: 12, attributes: [] },
            { type: :page, page: 13, attributes: [] },
            { type: :page, page: 14, attributes: [] },
          ]

          expect(result[5..11]).to eq expected
        end

        it 'should contain entries for the trailing pages' do
          expected = [
            { type: :page, page: 28, attributes: [] },
            { type: :page, page: 29, attributes: [] },
            { type: :page, page: 30, attributes: [] },
          ]

          # -1 is the 'next page' link
          expect(result[-4..-2]).to eq expected
        end

        it 'should contain proper separators' do
          [4, 12].each do |i|
            expect(result[i]).to eq({ type: :separator, page: nil, attributes: [:disabled] })
          end
        end
      end
    end

    describe '::prev_marker' do
      it 'should return a disabled marker if on the first page' do
        result = Pagination.prev_marker(1..10, 1)
        expect(result).to eq({ type: :prev, page: nil, attributes: [:disabled] })
      end

      it 'should return a marker to the previous page' do
        result = Pagination.prev_marker(1..10, 3)
        expect(result).to eq({ type: :prev, page: 2, attributes: [] })
      end
    end

    describe '::next_marker' do
      it 'should return a disabled marker if on the last page' do
        result = Pagination.next_marker(1..10, 10)
        expect(result).to eq({ type: :next, page: nil, attributes: [:disabled] })
      end

      it 'should return a marker to the next page' do
        result = Pagination.next_marker(1..10, 3)
        expect(result).to eq({ type: :next, page: 4, attributes: [] })
      end
    end

    describe '::page_subset' do
      context 'if the whole range fits into the subset' do
        let(:result) { Pagination.page_subset(1..10, 5, leading: 5, surrounding: 5, trailing: 5) }
        it 'should contain the whole range' do
          expect(result).to eq (1..10).to_a
        end
      end

      context 'if the range does not fit into the subset' do
        let(:result) { Pagination.page_subset(1..100, 50, leading: 4, surrounding: 6, trailing: 2) }
        it 'should contain the correct subset' do
          expect(result).to eq (
            [
              1, 2, 3, 4,
              44, 45, 46, 47, 48, 49,
              50,
              51, 52, 53, 54, 55, 56,
              99, 100,
            ]
          )
        end
      end

      context 'if there is some overlap' do
        let(:result) { Pagination.page_subset(1..100, 97, leading: 2, surrounding: 5, trailing: 10) }
        it 'should contain the correct subset' do
          expect(result).to eq (
            [1, 2, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100]
          )
        end
      end
    end

  end
end
