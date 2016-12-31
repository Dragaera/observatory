module Observatory
  module Config
    PAGINATION_SIZE_LEADERBOARD = ENV.fetch('PAGINATION_SIZE_LEADERBOARD', 15).to_i
    if PAGINATION_SIZE_LEADERBOARD < 1
      raise ArgumentError, "PAGINATION_SIZE_LEADERBOARD must be greater than 0. Was: #{ PAGINATION_SIZE_LEADERBOARD }"
    end
  end
end
