# Helper methods defined here can be accessed in any controller or view in the application

module Observatory
  class App
    module LeaderboardHelper
      SORT_ICON = 'glyphicon glyphicon-sort-by-attributes-alt'
      def sort_column(column, url_key: , sort_key: nil)
        sort_key ||= column.downcase.gsub(/\s/, '_')
        current_sort_key = params['sort_by']

        if column.downcase.gsub(/\s/, '_') == current_sort_key
          sort_icon = link_to("<span class ='#{ SORT_ICON } sort-col-icon'></span>".html_safe, url(*url_key, sort_by: sort_key))
        else
          sort_icon = link_to("<span class ='#{ SORT_ICON }'></span>".html_safe, url(*url_key, sort_by: sort_key))
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
    end

    helpers LeaderboardHelper
  end
end
