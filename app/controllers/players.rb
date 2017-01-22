Observatory::App.controllers :players do
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
