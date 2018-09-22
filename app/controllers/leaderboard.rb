Observatory::App.controllers :leaderboard do
  ALLOWED_SORT_COLUMNS = %w(skill score level experience time_total time_marine time_alien time_commander score_per_second)
  get :players, map: '/leaderboard' do
    sort_by = params.fetch('sort_by', 'skill')
    page = params.fetch('page', 1).to_i
    page = 1 if page < 1

    begin
      last_active_after = Date.strptime(
        params.fetch('last_active_after', ''),
        '%Y-%m-%d'
      )
    rescue ArgumentError
      last_active_after = nil
    end

    redirect url(:leaderboard, :players) unless ALLOWED_SORT_COLUMNS.include? sort_by

    sort_param = Sequel[:player_data_points][sort_by]
    # Graph ensures that column names will be full-qualified, so no conflicts will happen.
    @players = Player.
      select(:id, :last_update_at).
      eager(:current_player_data_point).
      exclude(current_player_data_point_id: nil).
      graph(
        :player_data_points,
        { id: :current_player_data_point_id },
        join_type: :inner
      ).
      order(Sequel.desc(sort_param))

    if last_active_after
      logger.debug "Filtering by last activity: #{ last_active_after }"
      @players = @players.where {
        Sequel[:player_data_points][:created_at] >= last_active_after
      }
    else
      logger.debug 'Skipping filtering by last activity.'
    end

    @players = @players.paginate(page, Observatory::Config::Leaderboard::PAGINATION_SIZE)

    render 'players'
  end
end
