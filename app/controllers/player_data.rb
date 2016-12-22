require 'hive_stalker'

Observatory::App.controllers :player_data do

  get :index, map: '/' do
    if params.key? 'steam_account_id'
      id = params.fetch('steam_account_id')
      stalker = HiveStalker::Stalker.new()
      begin
        @data = stalker.get_player_data(id)
      rescue HiveStalker::APIError => e
      rescue ArgumentError => e
      end
    end
    render 'index'
  end
end
