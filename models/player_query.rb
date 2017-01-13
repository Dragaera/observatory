class PlayerQuery < Sequel::Model
  alias_method :pending?, :pending
  alias_method :success?, :success

  plugin :validation_helpers
  def validate
    validates_presence [:query]
  end

  def execute(resolver: nil, stalker: nil)
    resolver ||= Observatory::SteamID
    stalker ||= HiveStalker::Stalker.new

    begin
      update(account_id: resolver.resolve(query))
      @@rate_limit.add('hive.total', 1)
      @@rate_limit.add('hive.get_player_data', 1)
      data = stalker.get_player_data(account_id)
      player = Player.from_player_data(data)

      update(pending: false,
             success: true,
             executed_at: DateTime.now)

      return player

    rescue ArgumentError, HiveStalker::APIError => e
      update(pending: false,
             success: false,
             executed_at: DateTime.now,
             error_message: e.message)

      return nil
    end
  end
end
