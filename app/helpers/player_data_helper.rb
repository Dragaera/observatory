# Helper methods defined here can be accessed in any controller or view in the application

module Observatory
  class App
    module PlayerDataHelper
      def get_player_data(steam_id)
        # Todo: Special return values (nil here) seems an awful lot like C. ;)
        stalker = HiveStalker::Stalker.new()
        { result: stalker.get_player_data(steam_id), error: nil }
      rescue ArgumentError => e
        { result: nil, error: e }
      rescue HiveStalker::APIError => e
        { result: nil, error: e }
      end
    end

    helpers PlayerDataHelper
  end
end
