Observatory::App.controllers :player_graphs, parent: :player do
  get :skill, provides: :json do
    @player = get_or_404(Player, params['player_id'])

    [
      {
        name: 'Skill',
        yAxisID: 'skill',
        data: @player.
                player_data_points_dataset.
                where(relevant: true).
                map { |point| [point.created_at.iso8601, point.skill] },
      },
      # https://github.com/ankane/chartkick.js/issues/79
      # {
      #   name: 'Score / Minute',
      #   yAxisID: 'score_per_second',
      #   data: @player.
      #           player_data_points_dataset.
      #           where(relevant: true).
      #           map { |point| [point.created_at.iso8601, (point.score_per_second * 60).round(2)] },
      # },
    ].to_json
  end

  get :playtime, provides: :json do
    @player = get_or_404(Player, params['player_id'])

    [
      {
        name: 'Aliens',
        data: @player.
                player_data_points_dataset.
                where(relevant: true).
                map { |point| [point.created_at.iso8601, (point.time_alien / 3600.0).round(2)] }
      },
      {
        name: 'Marines',
        data: @player.
                player_data_points_dataset.
                where(relevant: true).
                map { |point| [point.created_at.iso8601, (point.time_marine / 3600.0).round(2)] }
      },
    ].to_json
  end
end
