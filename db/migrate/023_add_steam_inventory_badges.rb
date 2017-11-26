Sequel.migration do
  up do
    alter_table :badges do
      # All existing badges are of type 'hive'
      add_column :type, String, default: 'hive', null: false
      set_column_default :type, nil

      add_index  [:key, :type], unique: true
    end

    group_nct_early_17 = from(:badge_groups).insert(name: 'NCT Early 2017', sort: 7)
    group_nct_late_17  = from(:badge_groups).insert(name:  'NCT Late 2017', sort: 8)
    group_ensl_s11 =     from(:badge_groups).insert(name: 'ENSL S11', sort: 9)

    [
      [1, 'NCT Early 2017 Gold',   'nct_17_gold.png',   '2167766106', group_nct_early_17],
      [2, 'NCT Early 2017 Silver', 'nct_17_silver.png', '2167564054', group_nct_early_17],
      [3, 'NCT Early 2017 Blue',   'nct_17_blue.png',   '2167567673', group_nct_early_17],

      [1, 'NCT Late 2017 Gold',   'nct_17_gold.png',   '2603900242', group_nct_late_17],
      [2, 'NCT Late 2017 Silver', 'nct_17_silver.png', '2603901037', group_nct_late_17],
      [3, 'NCT Late 2017 Blue',   'nct_17_blue.png',   '2603897726', group_nct_late_17],

      # ENSL S11 Div1/2 Silver?
      [3, 'ENSL S11 Div 1 Gold', 'ensl_s11.png', '2492755999', group_ensl_s11],
      [3, 'ENSL S11 Div 2 Gold', 'ensl_s11.png', '2493137347', group_ensl_s11],

      # WC 14
      #  -> silver 2148135690
      # March Mod Madness
      # -> silver 2293500413
      # PAX 12
      # Skulk Challenge
      #
    ].each do |ary|
      from(:badges).insert(sort: ary[0], name: ary[1], image: ary[2], key: ary[3], badge_group_id: ary[4], type: 'steam')
    end
  end

  down do
    from(:badges).where(type: 'steam').delete
    from(:badge_groups).where(name: ['NCT Early 2017', 'NCT Late 2017', 'ENSL S11']).delete

    alter_table :badges do
      drop_index [:key, :type]
      drop_column :type
    end
  end
end
