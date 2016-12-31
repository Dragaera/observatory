Observatory::App.controllers :leaderboard do
  ALLOWED_SORT_COLUMNS = %w(skill score level experience time_total time_marine time_alien time_commander)
  get :players, map: '/leaderboard' do
    sort_by = params.fetch('sort_by', 'skill')
    redirect url(:leaderboard, :players) unless ALLOWED_SORT_COLUMNS.include? sort_by

    sort_param = "player_data__#{ sort_by }".to_sym
    # Graph ensures that column names will be full-qualified, so no conflicts will happen.
    @players= Player.graph(:player_data, id: :current_player_data_id).order(Sequel.desc(sort_param))
    render 'players'
  end
end
