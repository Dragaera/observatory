# Helper methods defined here can be accessed in any controller or view in the application

module Observatory
  class App
    module PlayerHelper
      def player_profile_pagination_link(player_id, page)
        link_to page, url(:players, :profile, id: player_id, page: page)
      end

      def player_pagination_link(page, filter: nil, badges: nil, last_active_after: nil)
        link_to page, url(:players, :index, page: page, filter: filter, badges: badges, last_active_after: last_active_after)
      end

      def player_rank_link(ranks, col)
        rank = ranks["rank_#{ col }".to_sym]
        # rank - 1 sincce it starts at 1, not at 0. Result + 1 since pages
        # start at 1, not 0.
        page = (rank - 1) / Observatory::Config::Leaderboard::PAGINATION_SIZE + 1
        link_to "##{ rank }", url(:leaderboard, :players, page: page, sort_by: col)
      end

      def gorge_query(steam_id)
        return player_statistics_null_object unless Observatory::Config::Gorge::BASE_URL

        opts = {
          connect_timeout: Observatory::Config::Gorge::CONNECT_TIMEOUT,
          timeout: Observatory::Config::Gorge::TIMEOUT,
        }

        if Observatory::Config::Gorge::HTTP_BASIC_USER && Observatory::Config::Gorge::HTTP_BASIC_PASSWORD
          opts[:user]     = Observatory::Config::Gorge::HTTP_BASIC_USER
          opts[:password] = Observatory::Config::Gorge::HTTP_BASIC_PASSWORD
        end

        client = Gorgerb::Client.new(
          Observatory::Config::Gorge::BASE_URL,
          opts
        )

        client.player_statistics(steam_id)
      rescue Gorgerb::Error => e
        player_statistics_null_object
      end
    end

    def player_statistics_null_object
      Gorgerb::PlayerStatistics.new(
        nil,
        Gorgerb::PlayerStatistics::KDR.new(nil, nil, nil),
        Gorgerb::PlayerStatistics::Accuracy.new(
          nil,
          nil,
          Gorgerb::PlayerStatistics::MarineAccuracy.new(nil, nil),
        ),
      )
    end

    helpers PlayerHelper
  end
end
