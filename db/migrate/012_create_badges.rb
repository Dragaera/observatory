Sequel.migration do
  up do
    create_table :badges do
      primary_key :id

      String :name,  null: false
      String :image, null: false
      String :key,   null: true

      DateTime :created_at
      DateTime :updated_at
    end

    [
      ['CDT',                'cdt.png',               'community_dev'],
      ['Commander',          'commander.png',         'commander'],
      ['Constellation',      'constellation.png',     'constellation'],
      ['Developer',          'dev.png',               'dev'],
      ['Retired Developer',  'dev_retired.png',        nil],
      ['Reinforced Tier 1',  'game_tier_1.png',       'reinforced1'],
      ['Reinforced Tier 2',  'game_tier_2.png',       'reinforced2'],
      ['Reinforced Tier 3',  'game_tier_3.png',       'reinforced3'],
      ['Reinforced Tier 4',  'game_tier_4.png',       'reinforced4'],
      ['Reinforced Tier 5',  'game_tier_5.png',       'reinforced5'],
      ['Reinforced Tier 6',  'game_tier_6.png',       'reinforced6'],
      ['Reinforced Tier 7',  'game_tier_7.png',       'reinforced7'],
      ['Reinforced Tier 8',  'game_tier_8.png',       'reinforced8'],
      ['Maptester',          'maptester.png',         'maptester'],
      ['NS1 Playtester',     'ns1_playtester.png',    nil],
      ['PAX 2012',           'pax_2012.png',          nil],
      ['Playtester',         'playtester.png',        'playtester'],
      ['Squad5 Blue',        'squad5_blue.png',       'squad5_blue'],
      ['Squad5 Silver',      'squad5_silver.png',     'squad5_silver'],
      ['Squad5 Gold',        'squad5_gold.png',       'squad5_gold'],
      ['WC 2013 Supporter',  'wc_2013_supporter.png', 'wc2013_supporter'],
      ['WC 2013 Silver',     'wc_2013_silver.png',    'wc2013_silver'],
      ['WC 2013 Gold',       'wc_2013_gold.png',      'wc2013_gold'],
      ['WC 2013 Shadow',     'wc_2013_shadow.png',    'wc2013_shadow'],
    ].each do |ary|
      from(:badges).insert(name: ary[0], image: ary[1], key: ary[2])
    end

    create_table :badges_players do
      foreign_key :badge_id,  :badges,  null: false
      foreign_key :player_id, :players, null: false

      primary_key [:badge_id, :player_id]
      index       [:player_id, :badge_id]

      Bool     :enabled, null: false, default: true
      DateTime :created_at
      DateTime :updated_at
    end
  end

  down do
    drop_table :badges_players
    drop_table :badges
  end
end
