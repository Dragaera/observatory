module Observatory
  class PreventLimboProfiles
    extend Resque::Plugins::JobStats

    @queue = :prevent_limbo_profiles
    @durations_recorded = Observatory::Config::Resque::DURATIONS_RECORDED

    def self.perform
      logger.info('Cleaning profiles in limbo')

      # Players where an update was scheduled a long time ago. Cleaning these
      # ensures that we'll reschedule an update even if the pending one died
      # without resetting `update_scheduled_at`.
      long_pending_updates = Player.where { update_scheduled_at <  Time.now - Observatory::Config::PlayerData::CLEAR_UPDATE_SCHEDULED_AT_DELAY }
      logger.info("Resetting long-pending updates of #{ long_pending_updates.count } players.")
      long_pending_updates.update(update_scheduled_at: nil)

      # Players where no update was scheduled, and none will be scheduled.
      # Might be results of race conditions like issue #36.
      no_future_updates = Player.where(update_scheduled_at: nil, next_update_at: nil)
      logger.info("Scheduling updates for #{ no_future_updates.count } players with no future updates happening.")
      no_future_updates.each do |player|
        player.async_update_data
      end
    end
  end
end
