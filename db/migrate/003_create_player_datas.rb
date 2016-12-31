Sequel.migration do
  up do
    create_table :player_data do
      primary_key :id
      foreign_key :player_id, :players, null: false, on_update: :cascade, on_delete: :cascade

      String  :alias,          null: false, index: true
      Integer :score,          null: false, index: true
      Integer :level,          null: false, index: true
      Integer :experience,     null: false, index: true
      Integer :skill,          null: false, index: true
      Integer :time_total,     null: false, index: true
      Integer :time_alien,     null: false, index: true
      Integer :time_marine,    null: false, index: true
      Integer :time_commander, null: false, index: true
      Float   :adagrad_sum,    null: false, index: true

      DateTime :created_at
      DateTime :updated_at

      index [:player_id, :created_at]
    end

    alter_table :players do
      add_foreign_key :current_player_data_id, :player_data
    end
  end

  down do
    alter_table :players do
      drop_foreign_key :current_player_data_id
    end

    drop_table :player_data
  end
end
