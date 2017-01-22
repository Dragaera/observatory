# Helper methods defined here can be accessed in any controller or view in the application

module Observatory
  class App
    module PlayerGraphsHelper
      def playtime_graph(player)
        area_chart(
          url(:player_graphs, :playtime, player_id: player.id),
          ytitle: 'Playtime [h]',
          stacked: true,
          curve: false,
          download: "playtime_#{ player.account_id }",
          library: {
            title: {
              display: true,
              text: 'Playtime',
            }
          }
        )
      end

      def skill_graph(player)
        line_chart(
          url(:player_graphs, :skill, player_id: player.id),
          ytitle: 'Skill',
          curve: false,
          label: 'Skill',
          download: "skill_#{ player.account_id }",
          legend: false,
          library: {
            title: {
              display: true,
              text: 'Skill',
            }
          }
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
