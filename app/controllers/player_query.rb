Observatory::App.controllers :player_query do
  get :new do
    render 'new'
  end

  post :new do
    @steam_account_id = params.fetch('steam_account_id')
    query = PlayerQuery.new(query: @steam_account_id)

    unless query.valid?
      flash[:error] = 'Could not query for data, please retry with a different term'
      redirect(url(:player_query, :new))
    end

    query.save

    unless Observatory::RateLimit::Hive.get_player_data?(type: :user)
      query.update(
        success: false,
        error_message: "Rate-limited: #{ Observatory::RateLimit::Hive.rate_limit.count('hive.total', 1) }"
      )
      flash[:error] = 'Too many queries, please wait a few seconds.'
      redirect(url(:player_query, :new))
    end

    player = query.execute
    if player.nil?
      flash[:error] = "Error: #{ query.error_message }"
      redirect(url(:player_query, :new))
    end
    redirect(url(:players, :profile, id: player.id))
  end
end
