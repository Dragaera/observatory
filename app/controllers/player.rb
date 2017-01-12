Observatory::App.controllers :player do
  get :profile, map: '/player/:id' do |id|
    @player = get_or_404(Player, id)

    render 'profile'
  end

  post :update, map: '/player/:id/update' do |id|
    @player = get_or_404(Player, id)
    Resque.enqueue(Observatory::PlayerUpdate, @player.id)
    redirect(url(:player, :profile, id: id))
  end
end
