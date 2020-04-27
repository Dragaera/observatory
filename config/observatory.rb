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

    module Timezone
      DATABASE = ENV.fetch('TIMEZONE_DATABASE', 'utc')
      APPLICATION = ENV.fetch('TIMEZONE_APPLICATION', 'utc')
      TYPECAST = ENV.fetch('TIMEZONE_TYPECAST', APPLICATION)
    end

    module Database
      ADAPTER  = ENV.fetch('DB_ADAPTER')
      HOST     = ENV['DB_HOST']
      PORT     = ENV['DB_PORT']
      DATABASE = ENV.fetch('DB_DATABASE')
      USER     = ENV['DB_USER']
      PASS     = ENV['DB_PASS']
    end

    module Resque
      WEB_PATH = ENV.fetch('RESQUE_WEB_PATH', nil)
      DURATIONS_RECORDED = ENV.fetch('RESQUE_DURATIONS_RECORDED', 1000).to_i
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
      PAGINATION_SIZE = ENV.fetch('PROFILE_PAGINATION_SIZE', 14).to_i
      PAGINATION_LEADING = ENV.fetch('PROFILE_PAGINATION_LEADING', 5).to_i
      PAGINATION_SURROUNDING = ENV.fetch('PROFILE_PAGINATION_TRAILING', 3).to_i
      PAGINATION_TRAILING = ENV.fetch('PROFILE_PAGINATION_TRAILING', 5).to_i

      module ENSL
        SHOW_TUTORIALS  = ENV.fetch('PROFILE_ENSL_SHOW_TUTORIALS', 'y') == 'y'
        SKILL_THRESHOLD = ENV.fetch('PROFILE_ENSL_SKILL_THRESHOLD', 2000).to_i
        TIME_THRESHOLD  = ENV.fetch('PROFILE_ENSL_TIME_THRESHOLD', 60 * 60 * 8).to_i
      end
    end

    module Player
      PAGINATION_SIZE = ENV.fetch('PLAYER_PAGINATION_SIZE', 30).to_i
      PAGINATION_LEADING = ENV.fetch('PLAYER_PAGINATION_LEADING', 5).to_i
      PAGINATION_SURROUNDING = ENV.fetch('PLAYER_PAGINATION_TRAILING', 3).to_i
      PAGINATION_TRAILING = ENV.fetch('PLAYER_PAGINATION_TRAILING', 5).to_i

      ERROR_THRESHOLD = ENV.fetch('PLAYER_ERROR_THRESHOLD', 3).to_i
      INVALID_RETENTION_TIME = ENV.fetch('PLAYER_INVALID_RETENTION_TIME', 60 * 60).to_i
    end

    module PlayerData
      INITIAL_DELAY = ENV.fetch('PLAYER_DATA_INITIAL_DELAY', 60).to_i
      BACKOFF_DELAY = ENV.fetch('PLAYER_DATA_BACKOFF_DELAY', 300).to_i

      CLEAR_UPDATE_SCHEDULED_AT_DELAY = ENV.fetch('PLAYER_DATA_CLEAR_UPDATE_SCHEDULED_AT_DELAY', 2 * 60 * 60).to_i

      EXPORT_ROOT = ENV.fetch('PLAYER_DATA_EXPORT_ROOT', '/mnt/observatory')
      EXPORT_EXPIRY_THRESHOLD = ENV.fetch('PLAYER_DATA_EXPORT_EXPIRY_THRESHOLD', 7 * 24 * 60 * 60).to_i

      SCORE_PER_SECOND_THRESHOLD = ENV.fetch('PLAYER_DATA_SCORE_PER_SECOND_THRESHOLD', 1).to_f
    end

    module RateLimiting
      module Hive
        TOTAL_THRESHOLD      = ENV.fetch('HIVE_RATE_LIMITING_TOTAL_THRESHOLD', 2).to_i
        TOTAL_INTERVAL       = ENV.fetch('HIVE_RATE_LIMITING_TOTAL_INTERVAL', 1).to_i

        USER_THRESHOLD       = ENV.fetch('HIVE_RATE_LIMITING_USER_THRESHOLD', 2).to_i
        USER_INTERVAL        = ENV.fetch('HIVE_RATE_LIMITING_USER_INTERVAL', 1).to_i

        BACKGROUND_THRESHOLD = ENV.fetch('HIVE_RATE_LIMITING_BACKGROUND_THRESHOLD', 2).to_i
        BACKGROUND_INTERVAL  = ENV.fetch('HIVE_RATE_LIMITING_BACKGROUND_INTERVAL', 1).to_i
      end

      module Steam
        TOTAL_THRESHOLD = ENV.fetch('STEAM_RATE_LIMITING_TOTAL_THRESHOLD', 1).to_i
        TOTAL_INTERVAL  = ENV.fetch('STEAM_RATE_LIMITING_TOTAL_INTERVAL', 3).to_i
      end
    end

    module Steam
      WEB_API_KEY  = ENV['STEAM_WEB_API_KEY']
      HTTP_PROXIES = ENV.fetch('STEAM_HTTP_PROXIES', '').split(',')
    end

    module Colour
      ALIEN  = ENV.fetch('COLOUR_ALIEN', '#FF0000')
      MARINE = ENV.fetch('COLOUR_MARINE', '#0000FF')
    end

    module Localization
      DATE_FORMAT     = ENV.fetch('LOCALIZATION_DATE_FORMAT', '%F')
      DATETIME_FORMAT = ENV.fetch('LOCALIZATION_DATETIME_FORMAT', '%FT%T%:z')
    end

    module Piwik
      ENABLED = ENV.fetch('PIWIK_ENABLED', 'false') == 'true'
      SERVER  = ENV['PIWIK_SERVER']
      SITE_ID = ENV['PIWIK_SITE_ID']
      if ENABLED && !(SERVER && SITE_ID)
        raise ArgumentError, "Must define PIWIK_SERVER and PIWIK_SITE_ID if Piwik integration enabled."
      end
    end

    module Gorge
      BASE_URL            = ENV['GORGE_BASE_URL']
      HTTP_BASIC_USER     = ENV['GORGE_HTTP_BASIC_USER']
      HTTP_BASIC_PASSWORD = ENV['GORGE_HTTP_BASIC_PASSWORD']
      CONNECT_TIMEOUT     = ENV.fetch('GORGE_CONNECT_TIMEOUT', 1).to_i
      TIMEOUT             = ENV.fetch('GORGE_TIMEOUT', 2).to_i
      STATISTICS_CLASSES  = ENV.fetch('GORGE_STATISTICS_CLASSES', 'n_30,n_100').split(',')
    end

    module Sentry
      DSN = ENV['SENTRY_DSN']

      def self.enabled?
        DSN && !DSN.empty?
      end
    end

    module MOTD
      ENABLED = ENV.fetch('MOTD_ENABLED', 'false') == 'true'
      MESSAGE = ENV['MOTD_MESSAGE']
    end

    module NSL
      ACCOUNTS_API_ENDPOINT = ENV.fetch('NSL_ACCOUNTS_API_ENDPOINT', 'https://www.ensl.org/api/v1/users')
      PROFILE_BASE_URL      = ENV.fetch('NSL_PROFILE_BASE_URL', 'https://www.ensl.org/users')
    end
  end
end
