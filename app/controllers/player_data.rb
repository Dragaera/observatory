require 'hive_stalker'

Observatory::App.controllers :player_data do

  get :single do
    if params.key? 'steam_account_id'
      @data = get_player_data(params.fetch('steam_account_id'))
      if @data[:result].nil?
        # `nil` indicates that something went awry with the request.
        flash[:error] = @data[:error].message
        redirect(url(:player_data, :single))
      end
    end
    render 'single'
  end

  get :multiple do
    if params.key? 'steam_account_ids'
      @steam_account_ids = params['steam_account_ids'].lines.map(&:strip).uniq
      @data = Hash[@steam_account_ids.map { |id| [id, get_player_data(id)] }]
    else
      @steam_account_ids = []
    end
    render 'multiple'
  end
end
