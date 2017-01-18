Sequel.migration do
  up do
    alter_table :player_data_points do
      add_column :reinforced_tier, String
      add_column :hive_player_id,  Integer, null: true, index: true

      add_index [:player_id, :hive_player_id]
    end

    # Migrate data originally stored in player model to data point model.
    players = from(:players)
    players.each do |player|
      player_data_points = from(:player_data_points).where(player_id: player[:id])
      player_data_points.update(
        reinforced_tier: player[:reinforced_tier],
        hive_player_id: player[:hive2_player_id]
      )
    end

    alter_table :player_data_points do
      set_column_not_null :hive_player_id
    end

    alter_table :players do
      drop_column :hive2_player_id
      drop_column :reinforced_tier
    end
  end

  down do
    alter_table :players do
      add_column :hive2_player_id, Integer, null: true, unique: true, index: true
      add_column :reinforced_tier, String
    end

    players = from(:players)
    players.each do |player_hsh|
      player_data_point = from(:player_data_points).where(player_id: player_hsh[:id]).order(Sequel.desc(:id)).first
      if player_data_point
        players.where(id: player_hsh[:id]).update(
          hive2_player_id: player_data_point[:hive_player_id],
          reinforced_tier: player_data_point[:reinforced_tier],
        )
      else
        # Well, what are you going to do. Random number?
        player.update(hive2_player_id: player[:account_id])
      end
    end

    alter_table :players do
      set_column_not_null :hive2_player_id
    end

    alter_table :player_data_points do
      drop_column :reinforced_tier
      drop_column :hive_player_id
    end
  end
end
