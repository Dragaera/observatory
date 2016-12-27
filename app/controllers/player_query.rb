Observatory::App.controllers :player_query do
  get :create, map: '/query' do
    render 'create'
  end

  post :create, map: '/query' do
    @steam_account_id = params.fetch('steam_account_id')
    query = PlayerQuery.new(query: @steam_account_id)

    unless query.valid?
      flash[:error] = 'Could not query for data, please retry with a different term'
      redirect(url(:player_query, :create))
    end

    query.save
    @data = query.execute
    if @data.nil?
      flash[:error] = "Error: #{ query.error_message }" if @data.nil?
      redirect(url(:player_query, :create))
    end
    render 'create'
  end
end
