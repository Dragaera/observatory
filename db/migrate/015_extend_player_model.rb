Sequel.migration do
  up do
    alter_table :players do
      add_column :enabled,       TrueClass, null: false, default: true
      add_column :error_count,   Integer,   null: false, default: 0
      add_column :error_message, String
    end
  end

  down do
    alter_table :players do
      drop_column :enabled
      drop_column :error_count
      drop_column :error_message
    end
  end
end
