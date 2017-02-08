require 'csv'

class PlayerDataExport < Sequel::Model
  STATUS_PENDING = 'PENDING'
  STATUS_DOING   = 'DOING'
  STATUS_SUCCESS = 'SUCCESS'
  STATUS_ERROR   = "ERROR"
  STATUS_EXPIRED = 'EXPIRED'

  plugin :validation_helpers
  def before_validation
    self.status ||= STATUS_PENDING
  end

  def validate
    validates_presence [:status]
    validates_includes [STATUS_PENDING, STATUS_DOING, STATUS_SUCCESS, STATUS_ERROR, STATUS_EXPIRED], :status
  end

  many_to_one :player

  def pending?
    status == STATUS_PENDING
  end

  def doing?
    status == STATUS_DOING
  end

  def success?
    status == STATUS_SUCCESS
  end

  def error?
    status == STATUS_ERROR
  end

  def expired?
    status == STATUS_EXPIRED
  end

  def async_create_csv
    Resque.enqueue(Observatory::PlayerDataExportJob, id)
  end

  def create_csv(io: nil)
    io ||= default_io(player.id)
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
      update(status: STATUS_SUCCESS)
    rescue IOError => e
      # That takes care of the most obviousy one, at least. But there's tons of
      # ERRNO:ENOACCESS and the likes.
      update(
        status: STATUS_ERROR,
        error_message: e.message,
      )
    ensure
      csv.close
    end
  end

  private
  def default_io(id)
    outfile = File.join(
      Observatory::Config::PlayerData::EXPORT_ROOT,
      "player_export_#{ id }_#{ Time.now.strftime('%Y%m%d_%H%M%S') }.csv"
    )

    update(file_path: outfile)

    File.open(outfile, 'w')
  end
end
