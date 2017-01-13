module Observatory
  module Config
    PAGINATION_SIZE_LEADERBOARD = ENV.fetch('PAGINATION_SIZE_LEADERBOARD', 30).to_i
    if PAGINATION_SIZE_LEADERBOARD < 1
      raise ArgumentError, "PAGINATION_SIZE_LEADERBOARD must be greater than 0. Was: #{ PAGINATION_SIZE_LEADERBOARD }"
    end

    REDIS_HOST = ENV.fetch('REDIS_HOST', '127.0.0.1')
    REDIS_PORT = ENV.fetch('REDIS_PORT', 6379).to_i
    RESQUE_WEB_PATH = ENV.fetch('RESQUE_WEB_PATH', nil)

    # Interval for automatic player data updates in hours.
    PLAYER_DATA_UPDATE_INTERVAL = ENV.fetch('PLAYER_DATA_UPDATE_INTERVAL', 24).to_i
    if PLAYER_DATA_UPDATE_INTERVAL <= 0
      raise ArgumentError, "PLAYER_DATA_UPDATE_INTERVAL must be greater than 0. Was: #{ PLAYER_DATA_UPDATE_INTERVAL }"
    end
  end
end
