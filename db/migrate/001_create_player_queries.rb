Sequel.migration do
  up do
    create_table :player_queries do
      primary_key :id

      String  :query,     null: false
      Integer :account_id
      Boolean :pending,   null: false, default: true
      Boolean :success
      String  :error_message

      DateTime :executed_at
      DateTime :created_at
      DateTime :updated_at

      index :pending
    end
  end

  down do
    drop_table :player_queries
  end
end
