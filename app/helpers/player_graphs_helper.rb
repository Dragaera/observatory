# Helper methods defined here can be accessed in any controller or view in the application

module Observatory
  class App
    module PlayerGraphsHelper
      def playtime_graph(player)
        area_chart(
          url(:player_graphs, :playtime, player_id: player.id),
          stacked: true,
          curve: false,
          download: "playtime_#{ player.account_id }",
        )
      end

      def skill_graph(player)
        line_chart(
          url(:player_graphs, :skill, player_id: player.id),
          curve: false,
          label: 'Skill',
          download: "skill_#{ player.account_id }",
          # https://github.com/ankane/chartkick.js/issues/79
          # library: {
          #   scales: {
          #     yAxes: [
          #       {
          #         id: 'skill',
          #         position: 'left',
          #       },
          #       {
          #         id: 'score_per_second',
          #         position: 'right',
          #         ticks: {
          #           min: 0,
          #           max: 20,
          #         }
          #       }
          #     ]
          #   }
          # }
        )
      end
    end

    helpers PlayerGraphsHelper
  end
end
