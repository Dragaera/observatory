Observatory::App.controllers :players do
  get :index do
    page = params.fetch('page', 1).to_i
    page = 1 if page < 1

    result_sets = []

    badges = params.fetch('badges', []).uniq.map { |id| Badge[id.to_i] }.compact

    search_param = params['filter']
    unless search_param
      result_sets << Player.dataset
    end

    # Numberic? Match for account ID
    if search_param =~ /^\d+$/
      result_sets << Player.by_account_id(search_param.to_i)
    end

    # Non-empty? Match for aliases
    if search_param
      result_sets << Player.by_any_alias(search_param)
    end

    # UNION the different results together
    result = result_sets.shift
    result_sets.each do |ds|
      result = result.union(ds)
    end

    if badges.any?
      player_ids = badges.map { |badge| badge.players_dataset.select(:id) }
      ids = player_ids.shift
      player_ids.each do |ds|
        ids = ids.union(ds)
      end

      result = result.where(id: ids)
    end

    @players = result.
      paginate(page, Observatory::Config::Player::PAGINATION_SIZE).
      order(:id)

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
