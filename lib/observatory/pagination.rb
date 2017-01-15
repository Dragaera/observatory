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

      out += page_subset_leading(page_range, leading: leading)
      out += page_subset_surrounding(page_range, current_page, surrounding: surrounding)
      out += page_subset_trailing(page_range, trailing: trailing)

      out.uniq.sort
    end

    def self.page_subset_leading(page_range, leading: )
      page_range.first(leading)
    end

    def self.page_subset_trailing(page_range, trailing: )
      page_range.last(trailing)
    end

    def self.page_subset_surrounding(page_range, current_page, surrounding: )
      out = []
      buffer = []
      page_range.each do |i|

        if i < current_page
          buffer << i
        elsif i == current_page
          out += buffer.last(surrounding).reverse
          out << i
        elsif i > current_page
          if out.count < surrounding * 2 + 1
            out << i
          end
        end

      end
      out
    end
  end
end
