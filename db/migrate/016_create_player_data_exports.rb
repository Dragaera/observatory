Sequel.migration do
  up do
    create_table :player_data_exports do
      primary_key :id
      foreign_key :player_id, :players, null: false, on_update: :cascade, on_delete: :cascade

      String :file_path
      String :status, null: false, default: 'PENDING', index: true
      String :error_message

      DateTime :created_at
      DateTime :updated_at
    end
  end

  down do
    drop_table :player_data_exports
  end
end
