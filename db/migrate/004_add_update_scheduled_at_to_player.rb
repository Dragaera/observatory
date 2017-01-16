Sequel.migration do
  up do
    alter_table :players do
      add_column :update_scheduled_at, DateTime, index: true
    end
  end

  down do
    alter_table :players do
      drop_column :update_scheduled_at
    end
  end
end
