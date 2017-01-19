Observatory::App.controllers :leaderboard do
  ALLOWED_SORT_COLUMNS = %w(skill score level experience time_total time_marine time_alien time_commander)
  get :players, map: '/leaderboard' do
    sort_by = params.fetch('sort_by', 'skill')
    page = params.fetch('page', 1).to_i
    page = 1 if page < 1

    redirect url(:leaderboard, :players) unless ALLOWED_SORT_COLUMNS.include? sort_by

    sort_param = "player_data_points__#{ sort_by }".to_sym
    # Graph ensures that column names will be full-qualified, so no conflicts will happen.
    @players= Player.
      exclude(current_player_data_point_id: nil).
      graph(:player_data_points, id: :current_player_data_point_id).
      order(Sequel.desc(sort_param)).
      paginate(page, Observatory::Config::Leaderboard::PAGINATION_SIZE)
    render 'players'
  end
end
