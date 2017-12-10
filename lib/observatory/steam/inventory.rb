# coding: utf-8

require 'typhoeus'

module Observatory
  module Steam
    class Inventory
      # 4920 is NS2's app ID, 2 a magic parameter to make it list items (rather
      # than eg trading cards).
      BASE_URL = 'http://steamcommunity.com/inventory/%{steam_id_64}/4920/2'

      # TODO: This will work fine as long as we have one worker process only,
      # but once we have multiple worker processes, this will not work as
      # expected due to @@current_proxy_index being process-local.
      @@current_proxy_index = 0

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
        options = {}
        unless proxy_list.empty?
          options[:proxy] = next_proxy
        end

        response = Typhoeus.get(url, options)

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

      private
      def next_proxy
        return nil if proxy_list.empty?

        @@current_proxy_index = (@@current_proxy_index + 1) % proxy_list.length
        proxy_list[@@current_proxy_index]
      end

      def proxy_list
        Config::Steam::HTTP_PROXIES
      end
    end
  end
end
