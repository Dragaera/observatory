module Observatory
  class NSLAccountsSync
    extend Resque::Plugins::JobStats

    @queue = :nsl_accounts_sync
    @durations_recorded = Observatory::Config::Resque::DURATIONS_RECORDED

    def self.perform
      logger.info('NSL account cache: Updating')
      response = Typhoeus.get(Config::NSL::ACCOUNTS_API_ENDPOINT)

      if response.success?
        begin
          nsl_accounts = JSON.parse(response.body).fetch('users')
        rescue JSON::ParserError
          logger.error "Invalid JSON received from NSL accounts API: #{ response.body.inspect }"
          nsl_accounts = {}
        end
      elsif response.code == 0
        logger.error "Error while connecting to NSL accounts API: #{ response.return_message }"
        nsl_accounts = {}
      else
        logger.error "Non-success status code received from NSL accounts API: Code = #{ response.code }, body = #{ response.body}"
        nsl_accounts = {}
      end
      logger.debug('NSL account cache: API call finished')

      nsl_accounts.reject! do |hsh|
        hsh['steamid'].nil? || hsh['steamid'].empty? || hsh['id'].nil?
      end

      player_steam_id_map = Player.select_map([:account_id, :id]).to_h

      logger.debug('NSL account cache: Storing in redis')
      REDIS.pipelined do
        nsl_accounts = nsl_accounts.each do |hsh|
          steam_id_string = "STEAM_#{ hsh.fetch('steamid') }"
          nsl_id = hsh.fetch('id')
          nsl_name = hsh.fetch('username')

          steam_id = SteamID.from_string(steam_id_string)

          # Player with NSL account which is unknown to Observatory
          next unless player_steam_id_map.key? steam_id.account_id
          observatory_player_id = player_steam_id_map.fetch(steam_id.account_id)

          k = Player.nsl_account_cache_key(observatory_player_id)
          v = [
            'nsl_id', nsl_id,
            'nsl_name', nsl_name,
          ]
          REDIS.hmset(k, v)
        end

        REDIS.set('observatory:cache:nsl_accounts:updated', Time.now.iso8601)
      end
      logger.info('NSL account cache: Updated')
    end
  end
end
