Observatory::App.controllers :leaderboard do
  ALLOWED_SORT_COLUMNS = %w(skill score level experience time_total time_marine time_alien time_commander score_per_second)
  get :players, map: '/leaderboard' do
    sort_by = params.fetch('sort_by', 'skill')
    db_sort_param = Sequel[:player_data_points][sort_by]
    cache_sort_param = Player.leaderboard_cache_key(sort_by)

    @first_page = 1
    @current_page = params.fetch('page', 1).to_i
    @current_page = 1 if @current_page < 1
    @page_size = Observatory::Config::Leaderboard::PAGINATION_SIZE
    @last_page = (REDIS.zcard(cache_sort_param).to_f / @page_size).ceil

    redirect url(:leaderboard, :players) unless ALLOWED_SORT_COLUMNS.include? sort_by

    # Indices are zero-based, and include both ends
    start_index = (@current_page - 1) * @page_size
    end_index = start_index + @page_size - 1
    player_ids = REDIS.zrevrange(
      cache_sort_param,
      start_index,
      end_index
    ).
    map(&:to_i)

    # Graph ensures that column names will be full-qualified, so no conflicts will happen.
    @players = Player.
      select(:id, :last_update_at).
      eager(:current_player_data_point).
      graph(
        :player_data_points,
        { id: :current_player_data_point_id },
        join_type: :inner
      ).
      where(Sequel[:players][:id] => player_ids).
      order_by(
        Sequel.desc(db_sort_param),
        Sequel.desc(Sequel[:player_data_points][:created_at])
      )

    render 'players'
  end
end
