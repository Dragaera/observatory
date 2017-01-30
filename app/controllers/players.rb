Observatory::App.controllers :players do
  get :index do
    page = params.fetch('page', 1).to_i
    page = 1 if page < 1

    badges = params.fetch('badges', []).uniq.map { |id| Badge[id.to_i] }.compact

    search_param = params['filter']

    direct_results = []

    # Numeric? Match for account ID
    if search_param =~ /^\d+$/
      player = Player.by_account_id(search_param.to_i)
      direct_results << player if player # Might be a valid Steam ID for which we have no data
    end

    # Non-empty? Match for aliases
    if search_param
      result = Player.by_any_alias(search_param)

      # Might be a Steam ID
      begin
        resolver = Observatory::SteamID
        account_id = resolver.resolve(search_param)
        player = Player.by_account_id(account_id)
        direct_results << player if player # Might be a valid Steam ID for which we have no data
      rescue ArgumentError
        # Or not
      end
    else
      result = Player.dataset
    end

    if badges.any?
      player_ids = badges.map { |badge| badge.players_dataset.select(:id) }
      ids = player_ids.shift
      player_ids.each do |ds|
        ids = ids.union(ds)
      end

      result = result.where(id: ids)
      direct_results = direct_results.map do |ds|
        ds.where(id: ids)
      end
    end

    indirect_results = result.
      paginate(page, Observatory::Config::Player::PAGINATION_SIZE).
      order(:id)

    @results = {
      direct: direct_results.uniq,
      indirect: indirect_results,
    }

    render 'index'
  end

  get :profile, map: '/player/:id' do |id|
    @player = get_or_404(Player, id)

    page = params.fetch('page', 1).to_i
    page = 1 if page < 1

    @player_data_points = @player.
      recent_player_data.
      paginate(page, Observatory::Config::Profile::PAGINATION_SIZE)

    render 'profile'
  end

  post :update, map: '/player/:id/update' do |id|
    @player = get_or_404(Player, id)

    if @player.update_scheduled_at
      flash[:error] = 'There is already an updated scheduled for this player, please be patient.'
    elsif @player.async_update_data
      flash[:success] = 'Scheduled player update.'
    else
      flash[:error] = 'Failed to schedule player update.'
    end

    redirect(url(:players, :profile, id: id))
  end
end
