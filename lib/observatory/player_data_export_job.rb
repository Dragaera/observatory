! require 'csv'

module Observatory
  class PlayerDataExportJob
    extend Resque::Plugins::JobStats

    @queue = :player_data_export
    @durations_recorded = Observatory::Config::Resque::DURATIONS_RECORDED

    def self.perform(id)
      export = PlayerDataExport[id.to_i]
      if export.nil?
        logger.error "No export with id #{ id.inspect }"
        return false
      end

      export.create_csv
    end
  end
end
