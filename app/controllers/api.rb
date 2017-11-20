Observatory::App.controllers :api do
  before do
    api_authenticate!
  end

  get :player_data do
    identifier = params['identifier']
    halt 400, { error: "identifier missing or empty" }.to_json if identifier.nil? || identifier.empty?

    begin
      account_id = SteamID.from_string(
        identifier,
        api_key: Observatory::Config::Steam::WEB_API_KEY
      ).account_id
    rescue ArgumentError, WebApiError => e
      halt 400, e.message
    end

    player = Player.where(account_id: account_id).first
    halt 404, { error: "No player with id #{ account_id } on record" }.to_json unless player

    data = {
      adagrad_sum:      player.adagrad_sum,
      alias:            player.alias,
      badges:           player.badges.map(&:name),
      hive_player_id:   player.hive_player_id,
      experience:       player.experience,
      level:            player.level,
      score:            player.score,
      score_per_second: player.score_per_second,
      skill:            player.skill,
      time_total:       player.time_total,
      time_alien:       player.time_alien,
      time_marine:      player.time_marine,
      time_commander:   player.time_commander,

      last_updated_at:  player.last_update_at.iso8601,

      profile_url:      url(:players, :profile, id: player.id)
    }

    json(data)
  end
end
