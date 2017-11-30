# coding: utf-8

require 'typhoeus'

module Observatory
  module Steam
    class Inventory
      # 4920 is NS2's app ID, 2 a magic parameter to make it list items (rather
      # than eg trading cards).
      BASE_URL = 'http://steamcommunity.com/inventory/%{steam_id_64}/4920/2'

      def initialize(player)
        @player = player
        refresh
      end

      def url
        BASE_URL % { steam_id_64: SteamID::SteamID.new(@player.account_id).id_64 }
      end

      def badge_class_ids
        @inventory.fetch('assets', []).map { |asset| asset['classid'] }.uniq
      end

      def refresh
        response = Typhoeus.get(url)

        if response.success?
          begin
            @inventory = JSON.parse(response.body)
          rescue JSON::ParserError
            logger.error "Invalid JSON received from Steam inventory API: #{ response.body.inspect }"
            @inventory = {}
          end
        elsif response.code == 0
          logger.error "Error while connecting to API: #{ response.return_message }"
          @inventory = {}
        else
          logger.error "Non-success status code received from Steam inventory API: Code = #{ response.code }, body = #{ response.body}"
          @inventory = {}
        end
      end
    end
  end
end
