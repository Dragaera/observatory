module Observatory
  class ClearUpdateScheduledAt
    @queue = :clear_update_scheduled_at

    def self.perform
      Player.where { update_scheduled_at < Time.now - Observatory::Config::PlayerData::CLEAR_UPDATE_SCHEDULED_AT_DELAY }.each do |player|
        player.update(update_scheduled_at: nil)
      end
    end
  end
end
