Observatory::App.controllers :players do
  get :profile, map: '/player/:id' do |id|
    @player = get_or_404(Player, id)

    render 'profile'
  end

  post :update, map: '/player/:id/update' do |id|
    @player = get_or_404(Player, id)

    if @player.async_update_data
      flash[:success] = 'Scheduled player update'
    else
      flash[:error] = 'Failed to schedule player update'
    end

    redirect(url(:players, :profile, id: id))
  end
end
