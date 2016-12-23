# Helper methods defined here can be accessed in any controller or view in the application

module Observatory
  class App
    module PlayerDataHelper
      def get_player_data(steam_id)
        stalker = HiveStalker::Stalker.new()
        begin
          @data = stalker.get_player_data(steam_id)
        rescue HiveStalker::APIError => e
          msg = "Caught API Error: #{ e.message }"
          msg << " caused by: #{ e.cause.message }" if e.cause
          raise e
        end
      end
    end

    helpers PlayerDataHelper
  end
end
