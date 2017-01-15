module Observatory
  module Pagination
    def self.paginate(page_range, current_page, leading: 5, trailing: 5, surrounding: 5)
      out = []

      out << prev_marker(page_range, current_page)

      subset_range = page_subset(
        page_range,
        current_page,
        leading: leading,
        surrounding: surrounding,
        trailing: trailing
      )

      subset_range.each_cons(2) do |page, next_page|
        out << {
          type: :page,
          page: page,
          attributes: page == current_page ? [:active] : [],
        }

        if next_page - page > 1
          out << {
            type: :separator,
            page: nil,
            attributes: [:disabled],
          }
        end
      end
      # each_cons does not have an entry for the last one.
      out << {
        type: :page,
        page: subset_range.last,
        attributes: subset_range.last == current_page ? [:active] : [],
      }

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
      after_count = 0
      page_range.each do |i|

        if i < current_page
          buffer << i
        elsif i == current_page
          out += buffer.last(surrounding).reverse
          out << i
        elsif i > current_page
          if after_count < surrounding
            out << i
            after_count += 1
          end
        end

      end
      out
    end
  end
end
