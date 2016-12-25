# Helper methods defined here can be accessed in any controller or view in the application

module Observatory
  class App
    module PlayerDataHelper
      def get_player_data(steam_id)
        account_id = resolve_account_id(steam_id)
        stalker = HiveStalker::Stalker.new()
        { result: stalker.get_player_data(account_id), error: nil }
      rescue ArgumentError, HiveStalker::APIError => e
        { result: nil, error: e }
      end

      def resolve_account_id(steam_id)
        begin
          HiveStalker::SteamID.from_string(steam_id)
        rescue ArgumentError => e
          # Might be a vanity URL
          begin
            HiveStalker::SteamID.from_string(resolve_vanity_url(steam_id))
          rescue ArgumentError
            # Nope, rereaise old exception
            raise e
          end
        end
      end

      def resolve_vanity_url(url)
        vanity_url = url
        /^https?:\/\/steamcommunity\.com\/id\/([^\/]+)\/?$/.match(url) do |m|
          vanity_url = m[1]
        end

        steam_id = SteamId.resolve_vanity_url(vanity_url)
        if steam_id.nil?
          raise ArgumentError, "#{ vanity_url } could not be resolved to a Steam ID"
        else
          steam_id
        end
      end
    end

    helpers PlayerDataHelper
  end
end
