require 'hive_stalker'

Observatory::App.controllers :player_data do

  get :single do
    if params.key? 'steam_account_id'
      @data = get_player_data(params.fetch('steam_account_id'))
    end
    render 'single'
  end

  get :multiple do

  end
end
