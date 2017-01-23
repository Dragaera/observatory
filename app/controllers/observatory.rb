Observatory::App.controllers :observatory do
  get :stats, map: '/stats' do
    render 'stats'
  end

  get :scheduled_player_updates_graph do
    data = Player.
      group_by { Sequel.extract(:hour, :next_update_at) }.
      select {
      [
        Sequel.function(:count, 1),
        Sequel.extract(:hour, :next_update_at)
      ]
    }.
    map { |hsh| [hsh[:date_part].to_i, hsh[:count]] }.
    sort_by(&:first)

    data << [24, data.first[1]]

    data.to_json
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
