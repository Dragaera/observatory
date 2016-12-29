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
    @data = query.execute
    if @data.nil?
      flash[:error] = "Error: #{ query.error_message }" if @data.nil?
      redirect(url(:player_query, :single))
    end
    render 'single'
  end

  get :multiple, map: '/query/multiple' do
    @data = []
    render 'multiple'
  end

  post :multiple, map: '/query/multiple' do
    steam_account_ids = params.fetch('steam_account_ids').lines.map(&:chomp).uniq

    @data = Hash[steam_account_ids.map do |id|
      query = PlayerQuery.new(query: id)

      if query.valid?
        query.save

        data = query.execute
        [query, data]
      end
    end]

    render 'multiple'
  end
end
