Sequel.migration do
  up do
    alter_table :badges_players do
      drop_foreign_key [:badge_id]
      drop_foreign_key [:player_id]

      add_foreign_key [:badge_id],  :badges , null: false, on_update: :cascade, on_delete: :cascade
      add_foreign_key [:player_id], :players, null: false, on_update: :cascade, on_delete: :cascade
    end
  end

  down do
    alter_table :badges_players do
      drop_foreign_key [:badge_id]
      drop_foreign_key [:player_id]

      add_foreign_key [:badge_id],  :badges , null: false
      add_foreign_key [:player_id], :players, null: false
    end
  end
end
