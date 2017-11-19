class PlayerQuery < Sequel::Model
  alias_method :pending?, :pending
  alias_method :success?, :success

  plugin :validation_helpers
  def validate
    validates_presence [:query]
  end

  def execute(resolver: nil)
    begin
      resolver ||= SteamID
      update(account_id: resolver.from_string(query, api_key: Observatory::Config::Steam::WEB_API_KEY).account_id)
      player = Player.get_or_create(account_id: self.account_id)
      player.async_update_data

      update(pending: false,
             success: true,
             executed_at: DateTime.now)

      return player

    rescue ArgumentError, WebApiError => e
      update(pending: false,
             success: false,
             executed_at: DateTime.now,
             error_message: e.message)

      return nil
    end
  end
end
