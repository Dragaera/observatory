# Helper methods defined here can be accessed in any controller or view in the application

module Observatory
  class App
    module PlayerHelper
      def player_profile_pagination_link(player_id, page)
        link_to page, url(:players, :profile, id: player_id, page: page)
      end
    end

    helpers PlayerHelper
  end
end
