# Helper methods defined here can be accessed in any controller or view in the application

module Observatory
  class App
    module PlayerHelper
      def player_profile_pagination_link(player_id, page)
        link_to page, url(:players, :profile, id: player_id, page: page)
      end

      def player_pagination_link(page, filter: nil, badges: nil)
        link_to page, url(:players, :index, page: page, filter: filter, badges: badges)
      end

      def player_rank_link(ranks, col)
        rank = ranks.fetch("rank_#{ col }".to_sym)
        # rank - 1 sincce it starts at 1, not at 0. Result + 1 since pages
        # start at 1, not 0.
        page = (rank - 1) / Observatory::Config::Leaderboard::PAGINATION_SIZE + 1
        link_to "##{ rank }", url(:leaderboard, :players, page: page, sort_by: col)
      end
    end

    helpers PlayerHelper
  end
end
