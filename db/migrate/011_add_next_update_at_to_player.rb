Sequel.migration do
  up do
    alter_table(:players) do
      add_column :next_update_at, DateTime, null: true
      add_index  :next_update_at
    end
  end

  down do
    alter_table(:players) do
      drop_column :next_update_at
    end
  end
end
