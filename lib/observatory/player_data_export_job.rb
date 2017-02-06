! require 'csv'

module Observatory
  class PlayerDataExportJob
    extend Resque::Plugins::JobStats

    @queue = :player_data_export
    @durations_recorded = Observatory::Config::Resque::DURATIONS_RECORDED

    def self.perform(id, io: nil)
      player = Player[id.to_i]
      if player.nil?
        logger.error "No player with id #{ id.inspect }"
        return false
      end


      io ||= self.default_io(player.id)
      csv = CSV.new(
        io,
        write_headers: true,
        headers: %w(
            created_at
            adagrad_sum
            alias
            experience
            hive_player_id
            level
            reinforced_tier
            score
            skill
            time_total
            time_alien
            time_marine
            time_commander
            relevant
        )
      )
      begin
        # TODO: Theoretically we should fetch in batches. But with daily
        #       updates this will work fine for years.
        player.player_data_points_dataset.order_by(:id).each do |data|
          csv << [
            data.created_at.iso8601,
            data.adagrad_sum,
            data.alias,
            data.experience,
            data.hive_player_id,
            data.level,
            data.reinforced_tier,
            data.score,
            data.skill,
            data.time_total,
            data.time_alien,
            data.time_marine,
            data.time_commander,
            data.relevant,
          ]
        end
      ensure
        csv.close
      end
    end

    private
    def self.default_io(id)
      outfile = File.join(
        Observatory::Config::PlayerData::EXPORT_ROOT,
        "player_export_#{ id }_#{ Time.now.strftime('%Y%m%d_%H%M%S') }.csv"
      )

      File.open(outfile, 'w')
    end
  end
end
