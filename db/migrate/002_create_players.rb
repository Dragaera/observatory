Sequel.migration do
  up do
    create_table :players do
      primary_key :id

      Integer :hive2_player_id, null: false, unique: true, index: true
      Integer :account_id,      null: false, unique: true, index: true
      String  :reinforced_tier

      DateTime :created_at
      DateTime :updated_at
    end
  end

  down do
    drop_table :players
  end
end
