# Helper methods defined here can be accessed in any controller or view in the application

module Observatory
  class App
    module LeaderboardHelper
      SORT_ICON = 'glyphicon glyphicon-sort-by-attributes-alt'
      def sort_column(column, url_key: , sort_key: nil)
        if column.is_a? Array
          column, sort_key = *column
        else
          sort_key = column.downcase.gsub(/\s/, '_')
        end

        current_sort_key = params['sort_by']
        current_page = params['page']
        last_active_after = params['last_active_after']

        if sort_key == current_sort_key
          sort_icon = link_to("<span class ='#{ SORT_ICON } sort-col-icon'></span>".html_safe, url(*url_key, sort_by: sort_key, page: current_page, last_active_after: last_active_after))
        else
          sort_icon = link_to("<span class ='#{ SORT_ICON }'></span>".html_safe, url(*url_key, sort_by: sort_key, page: current_page, last_active_after: last_active_after))
        end

        "#{ column } #{ sort_icon }".html_safe
      end

      def highlight_sort_column(column, sort_param = nil)
        sort_param ||= params['sort_by']
        if sort_param.to_s == column.downcase.gsub(/\s/, '_')
          icon = '<span class="glyphicon glyphicon-sort>"'
          "#{ column }#{ icon }".html_safe
        else
          column
        end
      end

      def leaderboard_pagination_link(page)
        link_to page, url(:leaderboard, :players, sort_by: params['sort_by'], last_active_after: params['last_active_after'], page: page)
      end
    end

    helpers LeaderboardHelper
  end
end
