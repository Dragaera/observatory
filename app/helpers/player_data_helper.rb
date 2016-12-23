# Helper methods defined here can be accessed in any controller or view in the application

module Observatory
  class App
    module PlayerDataHelper
      def get_player_data(steam_id)
        # Todo: Settingi flash messages in a helper feels dirty.
        # And special return values (nil here) seems an awful lot like C. ;)
        stalker = HiveStalker::Stalker.new()
        stalker.get_player_data(steam_id)
      rescue ArgumentError => e
        flash[:error] = e.message
        nil
      rescue HiveStalker::APIError => e
        msg = e.message
        msg << " caused by: #{ e.cause.message }" if e.cause
        flash[:error] = msg
        nil
      end
    end

    helpers PlayerDataHelper
  end
end
