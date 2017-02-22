Sequel.migration do
  up do
    create_table :users do
      primary_key :id

      String :user,    null: false, unique: true
      String :password, null: false
      Bool   :active,  null: false, default: true

      DateTime :last_signin_at
      DateTime :created_at
      DateTime :updated_at
    end
  end

  down do
    drop_table :users
  end
end
