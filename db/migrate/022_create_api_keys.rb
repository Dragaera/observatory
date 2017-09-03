Sequel.migration do
  up do
    create_table :api_keys do
      primary_key :id

      String  :token, null: false, unique: true, size: 32
      String  :title, null: false, size: 30
      String  :description
      Boolean :active, null: false, default: true

      DateTime :last_used_at
      DateTime :created_at
      DateTime :updated_at
    end
  end

  down do
    drop_table :api_keys
  end
end
