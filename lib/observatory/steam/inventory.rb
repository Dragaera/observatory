# coding: utf-8

require 'typhoeus'

module Observatory
  module Steam
    class Inventory
      # 4920 is NS2's app ID, 2 a magic parameter to make it list items (rather
      # than eg trading cards).
      BASE_URL = 'http://steamcommunity.com/inventory/%{steam_id_64}/4920/2'

      CURRENT_PROXY_INDEX_KEY = 'observatory:current_proxy_index'

      def initialize(player)
        @player = player
        @redis  = Redis.new(host: Config::Redis::HOST, port: Config::Redis::PORT)
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

        proxy_list[next_proxy_index]
      end

      def proxy_list
        Config::Steam::HTTP_PROXIES
      end

      # This is not thread-safe, and might lead to race conditions. However, a
      # race condition might at most lead to a proxy being used twice in a row
      # - which will not cause any direct issues.
      def next_proxy_index
        i = @redis.incr(CURRENT_PROXY_INDEX_KEY) % proxy_list.length
        @redis.set(CURRENT_PROXY_INDEX_KEY, i)

        i
      end
    end
  end
end
