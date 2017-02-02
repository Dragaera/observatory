module Observatory
  class DeleteInvalidPlayers
    extend Resque::Plugins::JobStats

    @queue = :delete_invalid_players
    @durations_recorded = Observatory::Config::Resque::DURATIONS_RECORDED

    def self.perform()
      Player.
        where(
          current_player_data_point_id: nil,
          enabled: false,
      ).
      where { created_at < Time.now - Observatory::Config::Player::INVALID_RETENTION_TIME }.
      each do |player|
        logger.info "Deleting player #{ player.inspect }"
        player.delete
      end
    end
  end
end
