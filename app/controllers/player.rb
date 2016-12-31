Observatory::App.controllers :player do
  get :profile, map: '/players/:id' do |id|
    @player = get_or_404(Player, id)

    render 'profile'
  end
end
