module Observatory
  module RateLimit
    @@rate_limit = Ratelimit.new(
      redis: Redis.new(
        host: Observatory::Config::REDIS_HOST,
        port: Observatory::Config::REDIS_PORT
      )
    )

    def self.rate_limit
      @@rate_limit
    end

    def self.log_get_player_data(type: )
      log_hive_query

      if type == :user
        @@rate_limit.add('hive.get_player_data.user', 1)
      elsif type == :background
        @@rate_limit.add('hive.get_player_data.background', 1)
      else
        raise ArgumentError, "Invalid type given: #{ type.inspect }"
      end
    end

    def self.log_hive_query
      @@rate_limit.add('hive.total', 1)
    end
  end
end
