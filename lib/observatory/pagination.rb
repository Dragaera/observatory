module Observatory
  module Pagination
    def self.paginate(page_range, current_page, leading: 5, trailing: 5, surrounding: 5)
      out = []

      out << prev_marker(page_range, current_page)

      subset_range = page_subset(page_range, current_page, leading: leading, surrounding: surrounding, trailing: trailing)
      subset_range.each do |i|
        out << {
          type: :page,
          page: i,
          attributes: i == current_page ? [:active] : [],
        }
      end

      out << next_marker(page_range, current_page)

      out
    end

    def self.prev_marker(page_range, current_page)
      if current_page == page_range.first
        { type: :prev, page: nil, attributes: [:disabled] }
      else
        { type: :prev, page: current_page - 1, attributes: [] }
      end
    end

    def self.next_marker(page_range, current_page)
      if current_page == page_range.last
        { type: :next, page: nil, attributes: [:disabled] }
      else
        { type: :next, page: current_page + 1, attributes: [] }
      end
    end

    def self.page_subset(page_range, current_page, leading: , surrounding: , trailing: )
      out = []

      out += page_range.first(leading)

      buffer = []
      surrounding_before = []
      surrounding_after = []

      page_range.each do |i|
        if i < current_page
          buffer << i
        elsif i == current_page
          # Try to get surrounding members on LHS.
          surrounding.times do
            surrounding_before << buffer.pop unless buffer.empty?
          end
          out += surrounding_before.reverse

          # Add page itself
          out << i
        elsif i > current_page
          # Add following items to buffer until enough present - or range
          # empty.
          if surrounding_after.count < surrounding
            surrounding_after << i
          else
            break
          end
        end
      end

      out += surrounding_after

      out += page_range.last(trailing)

      out.sort.uniq
    end
  end
end
