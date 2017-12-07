Observatory::App.controllers :players do
  get :index do
    page = params.fetch('page', 1).to_i
    page = 1 if page < 1

    badges = params.fetch('badges', []).uniq.map { |id| Badge[id.to_i] }.compact

    search_param = params['filter']

    direct_results = []

    # Numeric? Match for account ID
    if search_param =~ /^\d+$/
      logger.debug "Searching for account ID #{ search_param }"
      player = Player.by_account_id(search_param.to_i)
      if player
        direct_results << player
        logger.debug "Found player: #{ player }"
      else
        # Might be a valid Steam ID for which we have no data
        logger.debug 'No matching player found'
      end
    end

    # Non-empty? Match for aliases
    if search_param && !search_param.empty?
      indirect_results = Player.by_current_alias(search_param)

      # Might be a Steam ID
      begin
        logger.debug "Searching for SteamID #{ search_param }"
        account_id = SteamID.from_string(search_param, api_key: Observatory::Config::Steam::WEB_API_KEY).account_id
        logger.debug "Resolved to #{ account_id } as Steam ID"

        player = Player.by_account_id(account_id)
        # Might be a valid Steam ID for which we have no data
        if player
          logger.debug "Found player: #{ player.inspect }"
          direct_results << player
        else
          logger.debug 'No matching player found'
        end
      rescue ArgumentError, WebApiError
        # Or not
        logger.debug 'Not a valid Steam ID'
      end
    else
      indirect_results = Player.by_current_alias(nil)
    end

    if badges.any?
      player_ids = badges.map { |badge| badge.players_dataset.select(:id) }
      ids = player_ids.shift
      player_ids.each do |ds|
        ids = ids.union(ds)
      end

      # Limit direct and indirect results to those who also own the specified
      # badges.
      # Mind that this is actually not a plain Player dataset, but a join on
      # data points, so care must be taken to refer to the propre `id`.
      indirect_results = indirect_results.where(Sequel[:players][:id] => ids)
      direct_results = direct_results.select do |player|
        ids.map(&:id).include? player.id
      end
    end

    indirect_results = indirect_results.
      exclude(Sequel[:players][:id] => direct_results.uniq.map(&:id)).
      paginate(page, Observatory::Config::Player::PAGINATION_SIZE)

    @results = {
      direct: direct_results.uniq,
      indirect: indirect_results
    }

    render 'index'
  end

  get :profile_direct, map: '/player' do
    steam_id = params['steam_id']
    if steam_id.nil? || steam_id.empty?
      logger.warn "[Direct Profile Search]: Missing Steam ID (Steam ID = #{ steam_id })"
      return 400, 'steam_id param missing'
    end

    player = Player.get_or_create(steam_id: steam_id)
    if player
      logger.info "[Direct Profile Search]: Success (Steam ID = #{ steam_id })"
      redirect url_for(:players, :profile, id: player.id)
    else
      logger.warn "[Direct Profile Search]: No such player (Steam ID = #{ steam_id })"
      return 404, 'Unknown Steam ID'
    end
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

  post :export, map: '/player/:id/export' do |id|
    player = get_or_404(Player, id)

    export = player.export_data
    redirect(url(:player_data_exports, :show, player_id: player.id, id: export.id))
  end
end
