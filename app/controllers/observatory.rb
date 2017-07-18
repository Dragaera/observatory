Observatory::App.controllers :observatory do
  get :index, map: '/' do
    expires 60

    render 'index'
  end

  get :stats, map: '/stats' do
    render 'stats'
  end

  get :scheduled_player_updates_graph do
    data = Hash[
      Player.
        where { next_update_at < Time.now + 24 * 60 * 60 }.
        group_by { Sequel.extract(:hour, :next_update_at) }.
        select {
        [
          Sequel.function(:count, 1),
          Sequel.extract(:hour, :next_update_at)
        ]
        }.
        map { |hsh| [hsh[:date_part].to_i, hsh[:count]] }
    ]

    # TODO: Should support timezone specified in config
    current_hour = Time.now.utc.hour
    ((current_hour...24).to_a + (0...current_hour).to_a).map do |hour|
      [hour, data[hour]]
    end.to_json
  end

  get :player_update_frequencies_graph do
    UpdateFrequency.
      where(enabled: true).
      map { |f| [f.name, f.players_dataset.count] }.
      to_json
  end

  get :player_queries_graph do
    PlayerQuery.
      group_by { Sequel.cast(:created_at, :date) }.
      select { [Sequel.function(:count, 1), Sequel.cast(:created_at, :date)] }.
      map { |hsh| [hsh[:created_at], hsh[:count]] }.
      to_json
  end
end
