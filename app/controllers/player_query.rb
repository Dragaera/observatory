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

    if Observatory::RateLimit.rate_limit.exceeded?('hive.total', threshold: 1, interval: 1)
      query.update(
        success: false,
        error_message: "Rate-limited: #{ @@rate_limit.count('hive.total', 1) }"
      )
      flash[:error] = 'Too many queries, please wait a few seconds.'
      redirect(url(:player_query, :single))
    end

    player = query.execute
    if player.nil?
      flash[:error] = "Error: #{ query.error_message }"
      redirect(url(:player_query, :single))
    end
    redirect(url(:players, :profile, id: player.id))
  end
end
