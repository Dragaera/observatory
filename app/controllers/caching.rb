Observatory::App.controllers :caching do
  before do
    authenticate!
  end

  get :index do
    @caches = [
      {
        name: 'ranks',
        updated: REDIS.get('observatory:cache:ranks:updated'),
        purge_url: url(:caching, :purge_ranks)
      },
      {
        name: 'nsl_accounts',
        updated: REDIS.get('observatory:cache:nsl_accounts:updated'),
        purge_url: url(:caching, :purge_nsl_accounts)
      },
    ]

    render 'index'
  end

  post :purge_ranks do
    player_ids = Player.select_map(:id)
    REDIS.pipelined do
      player_ids.each do |id|
        REDIS.del Player.ranks_cache_key(id)
      end

      REDIS.del('observatory:cache:ranks:updated')
    end

    redirect(url(:caching, :index))
  end

  post :purge_nsl_accounts do
    player_ids = Player.select_map(:id)
    REDIS.pipelined do
      player_ids.each do |id|
        REDIS.del Player.nsl_account_cache_key(id)
      end

      REDIS.del('observatory:cache:nsl_accounts:updated')
    end

    redirect(url(:caching, :index))
  end
end
