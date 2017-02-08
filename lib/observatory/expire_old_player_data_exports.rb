module Observatory
  class ExpireOldPlayerDataExports
    extend Resque::Plugins::JobStats

    @queue = :expire_old_player_data_exports
    @durations_recorded = Observatory::Config::Resque::DURATIONS_RECORDED

    def self.perform
      expired_reports = PlayerDataExport.
        where { created_at < Time.now - Observatory::Config::PlayerData::EXPORT_EXPIRY_THRESHOLD}.
        # Keeping failed (and pending) ones for invevstigation.
        where(status: PlayerDataExport::STATUS_SUCCESS)

      expired_reports.each do |export|
        export.update(status: PlayerDataExport::STATUS_EXPIRED)
        logger.info "Expiring report #{ export.id }"
        if export.file_path && File.exist?(export.file_path)
          logger.info "Deleting export file: #{ export.file_path }"
          File.delete export.file_path
        end
      end
    end
  end
end
