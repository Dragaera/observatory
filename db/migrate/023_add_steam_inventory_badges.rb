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

    group_nct_17 = from(:badge_groups).insert(name: 'NCT 2017', sort: 7)
    [
      [1, 'NCT 2017 Gold',   'nct_17_gold.png',   '2167766106', group_nct_17],
      [2, 'NCT 2017 Silver', 'nct_17_silver.png', '2167564054', group_nct_17], [3, 'NCT 2017 Blue',   'nct_17_blue.png',   '2167567673', group_nct_17],
    ].each do |ary|
      from(:badges).insert(sort: ary[0], name: ary[1], image: ary[2], key: ary[3], badge_group_id: ary[4], type: 'steam')
    end
  end

  down do
    from(:badges).where(type: 'steam').delete
    from(:badge_groups).where(name: ['NCT 2017']).delete

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
