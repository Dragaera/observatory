class PlayerQuery < Sequel::Model
  alias_method :pending?, :pending
  alias_method :success?, :success

  plugin :validation_helpers
  def validate
    validates_presence [:query]
  end

  def execute(resolver: nil)
    resolver ||= Observatory::SteamID

    begin
      update(account_id: resolver.resolve(query))
      player = Player.get_or_create(account_id: self.account_id)
      player.async_update_data

      update(pending: false,
             success: true,
             executed_at: DateTime.now)

      return player

    rescue ArgumentError => e
      update(pending: false,
             success: false,
             executed_at: DateTime.now,
             error_message: e.message)

      return nil
    end
  end
end
