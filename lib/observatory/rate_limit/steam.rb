module Observatory
  module RateLimit
    module Steam
      KEY_TOTAL = 'steam.total'

      @@rate_limit = Ratelimit.new(
        'Steam queries',
        redis: Redis.new(
          host: Observatory::Config::Redis::HOST,
          port: Observatory::Config::Redis::PORT
        )
      )

      def self.rate_limit
        @@rate_limit
      end

      def self.steam_query?
        @@rate_limit.within_bounds?(
          KEY_TOTAL,
          threshold: ::Observatory::Config::RateLimiting::Steam::TOTAL_THRESHOLD,
          interval:  ::Observatory::Config::RateLimiting::Steam::TOTAL_INTERVAL
        )
      end

      def self.log_steam_query
        @@rate_limit.add(KEY_TOTAL, 1)
      end
    end
  end
end
