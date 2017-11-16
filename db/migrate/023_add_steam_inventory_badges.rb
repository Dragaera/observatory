Sequel.migration do
  up do
    alter_table :players do
      add_column :query_steam_inventory,      TrueClass, default: true, null: false
      add_column :steam_inventory_queried_at, DateTime
    end

    alter_table :badges do
      # All existing badges are of type 'hive'
      add_column :type, String, default: 'hive', null: false
      set_column_default :type, nil

      add_index  [:key, :type], unique: true
    end
  end

  down do
    from(:badges).where(type: 'steam').delete

    alter_table :badges do
      drop_index [:key, :type]
      drop_column :type
    end

    alter_table :players do
      drop_column :query_steam_inventory
      drop_column :steam_inventory_queried_at
    end
  end
end
