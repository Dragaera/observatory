Sequel.migration do
  up do
    alter_table :badges do
      # All existing badges are of type 'hive'
      add_column :type, String, default: 'hive', null: false
      set_column_default :type, nil

      add_index  [:key, :type], unique: true
    end

    group_nct_early_17 = from(:badge_groups).insert(name: 'NCT Early 2017', sort: 7)
    group_nct_late_17  = from(:badge_groups).insert(name: 'NCT Late 2017', sort: 8)
    group_ensl_s11     = from(:badge_groups).insert(name: 'ENSL S11', sort: 9)
    group_mm_17        = from(:badge_groups).insert(name: 'Mod Madness 2017', sort: 10)
    group_wc_14        = from(:badge_groups).insert(name: 'WC 2014', sort: 11)

    [
      [1, 'NCT Early 2017 Gold',   'nct_17_gold.png',   '2167766106', group_nct_early_17],
      [2, 'NCT Early 2017 Silver', 'nct_17_silver.png', '2167564054', group_nct_early_17],
      [3, 'NCT Early 2017 Blue',   'nct_17_blue.png',   '2167567673', group_nct_early_17],

      [1, 'NCT Late 2017 Gold',   'nct_17_gold.png',   '2603900242', group_nct_late_17],
      [2, 'NCT Late 2017 Silver', 'nct_17_silver.png', '2603901037', group_nct_late_17],
      [3, 'NCT Late 2017 Blue',   'nct_17_blue.png',   '2603897726', group_nct_late_17],

      [1, 'ENSL S11 Div 1 Gold', 'ensl_s11.png', '2492755999', group_ensl_s11],
      [2, 'ENSL S11 Div 2 Gold', 'ensl_s11.png', '2493137347', group_ensl_s11],

      [1, 'Mod Madness 2017 Gold',   'mod_madness_17_gold.png',   '2290135856', group_mm_17],
      [2, 'Mod Madness 2017 Silver', 'mod_madness_17_silver.png', '2293500413', group_mm_17],
      [3, 'Mod Madness 2017 Blue',   'mod_madness_17_blue.png',   '2290110214', group_mm_17],

      [1, 'WC 2014 Gold',          'wc_14_gold.png',   '2144554792', group_wc_14],
      [2, 'WC 2014 Silver',        'wc_14_silver.png', '2148135690', group_wc_14],
      [3, 'WC 2014 Semi-Finalist', 'wc_14_bronze.png', '2146631298', group_wc_14],
    ].each do |ary|
      from(:badges).insert(sort: ary[0], name: ary[1], image: ary[2], key: ary[3], badge_group_id: ary[4], type: 'steam')
    end

    # Fix previously-missing attribute.
    # Was set to `1` for all badges as part of migration 012.
    {
      "Developer" => 1,
      "Retired Developer" => 2,
      "CDT" => 3,
      "Constellation" => 1,
      "Maptester" => 2,
      "NS1 Playtester" => 3,
      "PAX 2012" => 4,
      "Playtester" => 5,
      "Commander" => 1,
      "Reinforced Tier 8" => 1,
      "Reinforced Tier 7" => 2,
      "Reinforced Tier 6" => 3,
      "Reinforced Tier 5" => 4,
      "Reinforced Tier 4" => 5,
      "Reinforced Tier 3" => 6,
      "Reinforced Tier 2" => 7,
      "Reinforced Tier 1" => 8,
      "Squad5 Gold" => 1,
      "Squad5 Silver" => 2,
      "Squad5 Blue" => 3,
      "WC 2013 Shadow" => 4,
      "WC 2013 Gold" => 5,
      "WC 2013 Silver" => 6,
      "WC 2013 Supporter" => 7
    }.each do |name, sort|
      from(:badges).where(name: name).update(sort: sort)
    end

    # Deactivate PAX badge since not trackable, as it's a DLC.
    from(:badges).where(name: 'PAX 2012', type: 'hive').delete

    # Unify some things
    group_wc_13_supporter = from(:badge_groups).where(name: 'WC 2013').first
    from(:badges).where(badge_group_id: group_wc_13_supporter[:id]).update(badge_group_id: group_wc_14)
    from(:badge_groups).where(name: 'WC 2013').delete
    from(:badges).where(key: 'wc2013_shadow').update(name: 'WC 2014 Shadow Supporter')
    from(:badges).where(key: 'wc2013_gold').update(name: 'WC 2014 Gold Supporter')
    from(:badges).where(key: 'wc2013_silver').update(name: 'WC 2014 Silver Supporter')
    from(:badges).where(key: 'wc2013_supporter').update(name: 'WC 2014 Supporter')

    {
      'UWE'              => 1,
      'Community'        => 2,
      'Squad 5'          => 3,

      'Ingame'           => 4,
      'Reinforced'       => 5,
      'WC 2014'          => 6,

      'NCT Early 2017'   => 7,
      'NCT Late 2017'    => 8,
      'Mod Madness 2017' => 9,

      'ENSL S11'         => 10,
    }.each do |name, sort|
      from(:badge_groups).where(name: name).update(sort: sort)
    end

    # Ensure sort order is guaranteed
    alter_table :badges do
      add_index  [:badge_group_id, :sort], unique: true
    end

    alter_table :badge_groups do
      add_index :sort, unique: true
    end
  end

  down do
    from(:badges).where(type: 'steam').delete

    # Temporary sort key to prevent unique index conflict.
    group_wc_13_supporter = from(:badge_groups).insert(sort: 100, name: 'WC 2013')
    from(:badges).where(key: 'wc2013_shadow').update(name: 'WC 2013 Shadow', badge_group_id: group_wc_13_supporter)
    from(:badges).where(key: 'wc2013_gold').update(name: 'WC 2013 Gold', badge_group_id: group_wc_13_supporter)
    from(:badges).where(key: 'wc2013_silver').update(name: 'WC 2013 Silver', badge_group_id: group_wc_13_supporter)
    from(:badges).where(key: 'wc2013_supporter').update(name: 'WC 2013 Supporter', badge_group_id: group_wc_13_supporter)

    group_community = from(:badge_groups).where(name: 'Community').first
    from(:badges).insert(sort: 4, name: 'PAX 2012', image: 'pax_2012.png', key: nil, badge_group_id: group_community[:id], type: 'hive')

    from(:badge_groups).where(name: ['NCT Early 2017', 'NCT Late 2017', 'ENSL S11', 'Mod Madness 2017', 'WC 2014']).delete

    alter_table :badges do
      drop_index [:key, :type]
      drop_index [:badge_group_id, :sort]
      drop_column :type
    end

    from(:badges).update(sort: 1)

    alter_table :badge_groups do
      drop_index :sort
    end

    {
      'UWE'              => 1,
      'Community'        => 2,
      'Ingame'           => 3,

      'Reinforced'       => 4,
      'Squad5'           => 5,
      'WC 2013'          => 6,
    }.each do |name, sort|
      from(:badge_groups).where(name: name).update(sort: sort)
    end
  end
end
