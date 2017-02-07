! require 'csv'

module Observatory
  class PlayerDataExportJob
    extend Resque::Plugins::JobStats

    @queue = :player_data_export
    @durations_recorded = Observatory::Config::Resque::DURATIONS_RECORDED

    def self.perform(id)
      player = Player[id.to_i]
      if player.nil?
        logger.error "No player with id #{ id.inspect }"
        return false
      end

      player.create_csv
    end
  end
end
