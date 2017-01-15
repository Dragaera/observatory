module Observatory
  module RateLimit
    KEY_GET_PLAYER_DATA_USER       = 'hive.get_player_data.user'
    KEY_GET_PLAYER_DATA_BACKGROUND = 'hive.get_player_data.background'
    KEY_TOTAL                      = 'hive.total'

    @@rate_limit = Ratelimit.new(
      'Hive queries',
      redis: Redis.new(
        host: Observatory::Config::Redis::HOST,
        port: Observatory::Config::Redis::PORT
      )
    )

    def self.rate_limit
      @@rate_limit
    end

    def self.hive_query?
      @@rate_limit.within_bounds?(
        KEY_TOTAL,
        threshold: ::Observatory::Config::RateLimiting::TOTAL_THRESHOLD,
        interval:  ::Observatory::Config::RateLimiting::TOTAL_INTERVAL
      )
    end

    def self.get_player_data?(type: )
      return false unless self.hive_query?

      if type == :user
        # puts "User queries in 10s: #{ @@rate_limit.count(KEY_GET_PLAYER_DATA_USER, 10) }"
        @@rate_limit.within_bounds?(
          KEY_GET_PLAYER_DATA_USER,
          threshold: Observatory::Config::RateLimiting::USER_THRESHOLD,
          interval:  Observatory::Config::RateLimiting::USER_INTERVAL
        )
      elsif type == :background
        @@rate_limit.within_bounds?(
          KEY_GET_PLAYER_DATA_BACKGROUND,
          threshold: Observatory::Config::RateLimiting::BACKGROUND_THRESHOLD,
          interval:  Observatory::Config::RateLimiting::BACKGROUND_INTERVAL
        )
      else
        raise ArgumentError, "Invalid type given: #{ type.inspect }"
      end
    end

    def self.log_get_player_data(type: )
      log_hive_query

      if type == :user
        @@rate_limit.add(KEY_GET_PLAYER_DATA_USER, 1)
      elsif type == :background
        @@rate_limit.add(KEY_GET_PLAYER_DATA_BACKGROUND, 1)
      else
        raise ArgumentError, "Invalid type given: #{ type.inspect }"
      end
    end

    def self.log_hive_query
      @@rate_limit.add(KEY_TOTAL, 1)
    end
  end
end
