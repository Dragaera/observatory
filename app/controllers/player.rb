Observatory::App.controllers :player do
  get :profile, map: '/player/:id' do |id|
    @player = get_or_404(Player, id)

    render 'profile'
  end
end
