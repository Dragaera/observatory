Observatory::App.controllers :player_query do
  get :single, map: '/query' do
    render 'single'
  end

  post :single, map: '/query' do
    @steam_account_id = params.fetch('steam_account_id')
    query = PlayerQuery.new(query: @steam_account_id)

    unless query.valid?
      flash[:error] = 'Could not query for data, please retry with a different term'
      redirect(url(:player_query, :single))
    end

    query.save
    player = query.execute
    if player.nil?
      flash[:error] = "Error: #{ query.error_message }"
      redirect(url(:player_query, :single))
    end
    redirect(url(:players, :profile, id: player.id))
  end
end
