module Observatory
  module Config
    if ENV['DEBUG']
      DEBUG = true
    else
      DEBUG = false
    end

    module Redis
      HOST = ENV.fetch('REDIS_HOST', '127.0.0.1')
      PORT = ENV.fetch('REDIS_PORT', 6379).to_i
    end

    module Database
      ADAPTER  = ENV.fetch('DB_ADAPTER', 'sqlite')
      HOST     = ENV['DB_HOST']
      DATABASE = ENV.fetch('DB_DATABASE', "db/observatory_#{ Padrino.env }.db")
      USER     = ENV['DB_USER']
      PASS     = ENV['DB_PASS']
    end

    module Resque
      WEB_PATH = ENV.fetch('RESQUE_WEB_PATH', nil)
    end

    module Leaderboard
      PAGINATION_SIZE = ENV.fetch('LEADERBOARD_PAGINATION_SIZE', 30).to_i
      if PAGINATION_SIZE < 1
        raise ArgumentError, "LEADERBOARD_PAGINATION_SIZE must be greater than 0. Was: #{ PAGINATION_SIZE }"
      end

      PAGINATION_LEADING = ENV.fetch('LEADERBOARD_PAGINATION_LEADING', 5).to_i
      PAGINATION_SURROUNDING = ENV.fetch('LEADERBOARD_PAGINATION_TRAILING', 3).to_i
      PAGINATION_TRAILING = ENV.fetch('LEADERBOARD_PAGINATION_TRAILING', 5).to_i
    end

    module Profile
      PAGINATION_SIZE = ENV.fetch('PROFILE_PAGINATION_SIZE', 7).to_i
      PAGINATION_LEADING = ENV.fetch('PROFILE_PAGINATION_LEADING', 5).to_i
      PAGINATION_SURROUNDING = ENV.fetch('PROFILE_PAGINATION_TRAILING', 3).to_i
      PAGINATION_TRAILING = ENV.fetch('PROFILE_PAGINATION_TRAILING', 5).to_i
    end

    module PlayerData
      INITIAL_DELAY = ENV.fetch('PLAYER_DATA_INITIAL_DELAY', 60).to_i
      BACKOFF_DELAY = ENV.fetch('PLAYER_DATA_BACKOFF_DELAY', 300).to_i

      CLEAR_UPDATE_SCHEDULED_AT_DELAY = ENV.fetch('PLAYER_DATA_CLEAR_UPDATE_SCHEDULED_AT_DELAY', 2 * 60 * 60).to_i
    end

    module RateLimiting
      TOTAL_THRESHOLD      = ENV.fetch('RATE_LIMITING_TOTAL_THRESHOLD', 2).to_i
      TOTAL_INTERVAL       = ENV.fetch('RATE_LIMITING_TOTAL_INTERVAL', 1).to_i

      USER_THRESHOLD       = ENV.fetch('RATE_LIMITING_USER_THRESHOLD', 2).to_i
      USER_INTERVAL        = ENV.fetch('RATE_LIMITING_USER_INTERVAL', 1).to_i

      BACKGROUND_THRESHOLD = ENV.fetch('RATE_LIMITING_BACKGROUND_THRESHOLD', 2).to_i
      BACKGROUND_INTERVAL  = ENV.fetch('RATE_LIMITING_BACKGROUND_INTERVAL', 1).to_i
    end

    module Steam
      WEB_API_KEY = ENV.fetch('STEAM_WEB_API_KEY')
    end
  end
end
