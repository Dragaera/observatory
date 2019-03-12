module Observatory
  class LeaderboardUpdate
    extend Resque::Plugins::JobStats

    @queue = :leaderboard_update
    @durations_recorded = Observatory::Config::Resque::DURATIONS_RECORDED

    def self.perform
      logger.debug('Leaderboard: Calculacting player ranks')
      ranks = Player.ranks([:skill, :score, :score_per_second, :experience]).map(&:to_hash)

      logger.debug('Leaderboard: Storing ranks in redis')
      REDIS.pipelined do
        ranks.each do |rank|
          k = Player.ranks_cache_key(rank[:player_id])
          v = [
            'skill',            rank.fetch(:rank_skill).to_s,
            'score',            rank.fetch(:rank_score).to_s,
            'score_per_second', rank.fetch(:rank_score_per_second).to_s,
            'experience',       rank.fetch(:rank_experience).to_s,
          ]
          REDIS.hmset(k, v)
        end

        REDIS.set('observatory:cache:ranks:updated', Time.now.iso8601)
      end
      logger.debug('Leaderboard: Ranks updated')
    end
  end
end

