Sequel.migration do
  up do
    alter_table :player_data_points do
      # Regenerate indices with old names
      drop_index :alias, name: 'player_data_alias_index'
      add_index  :alias

      drop_index :experience, name: 'player_data_experience_index'
      add_index  :experience

      drop_index :level, name: 'player_data_level_index'
      add_index  :level

      drop_index :score, name: 'player_data_score_index'
      add_index  :score

      drop_index :skill, name: 'player_data_skill_index'
      add_index  :skill

      drop_index :time_alien, name: 'player_data_time_alien_index'
      add_index  :time_alien

      drop_index :time_marine, name: 'player_data_time_marine_index'
      add_index  :time_marine

      drop_index :time_commander, name: 'player_data_time_commander_index'
      add_index  :time_commander

      drop_index :time_total, name: 'player_data_time_total_index'
      add_index  :time_total

      # Remove unneeded indices
      drop_index :adagrad_sum,                  name: 'player_data_adagrad_sum_index'
      drop_index [:player_id, :created_at],     name: 'player_data_player_id_created_at_index'
      drop_index [:player_id, :hive_player_id]

      # Recreate foreign key
      drop_foreign_key [:player_id], name: 'player_data_player_id_fkey'
      add_foreign_key  [:player_id], :players, on_update: :cascade, on_delete: :cascade
    end

    # Rename primary key
    run 'ALTER INDEX player_data_pkey RENAME TO player_data_points_pkey'
  end

  down do
    alter_table :player_data_points do
      # Remove new indicies
      drop_index :alias
      drop_index :experience
      drop_index :level
      drop_index :skill
      drop_index :score
      drop_index :time_alien
      drop_index :time_marine
      drop_index :time_commander
      drop_index :time_total

      # Recreate old-style indices
      add_index :adagrad_sum,               name: 'player_data_adagrad_sum_index'
      add_index :alias,                     name: 'player_data_alias_index'
      add_index :experience,                name: 'player_data_experience_index'
      add_index :level,                     name: 'player_data_level_index'
      add_index :score,                     name: 'player_data_score_index'
      add_index :skill,                     name: 'player_data_skill_index'
      add_index [:player_id, :created_at],  name: 'player_data_player_id_created_at_index'
      add_index :time_alien,                name: 'player_data_time_alien_index'
      add_index :time_marine,               name: 'player_data_time_marine_index'
      add_index :time_commander,            name: 'player_data_time_commander_index'
      add_index :time_total,                name: 'player_data_time_total_index'
      add_index [:player_id, :hive_player_id]

      # Recreate old-style foreign key
      drop_foreign_key [:player_id]
      add_foreign_key  [:player_id], :players, name: 'player_data_player_id_fkey', on_update: :cascade, on_delete: :cascade
    end

    # Rename to old-style primary key
    run 'ALTER INDEX player_data_points_pkey RENAME TO player_data_pkey'
  end
end
