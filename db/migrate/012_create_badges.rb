Sequel.migration do
  up do
    create_table :badge_groups do
      primary_key :id

      String :name, null: false
      Fixnum :sort, null: false, default: 0

      DateTime :created_at
      DateTime :updated_at
    end

    create_table :badges do
      primary_key :id

      foreign_key :badge_group_id, :badge_groups, null: false

      String :name,  null: false
      String :image, null: false
      String :key,   null: true
      Fixnum :sort,  null: false, default: 0

      DateTime :created_at
      DateTime :updated_at
    end

    group_uwe        = from(:badge_groups).insert(name: 'UWE', sort: 1)
    group_community  = from(:badge_groups).insert(name: 'Community', sort: 2)
    group_ingame     = from(:badge_groups).insert(name: 'Ingame', sort: 3)
    group_reinforced = from(:badge_groups).insert(name: 'Reinforced', sort: 4)
    group_squad5     = from(:badge_groups).insert(name: 'Squad 5', sort: 5)
    group_wc2013     = from(:badge_groups).insert(name: 'WC 2013', sort: 6)
    [
      [1, 'Developer',          'dev.png',               'dev',              group_uwe],
      [2, 'Retired Developer',  'dev_retired.png',        nil,               group_uwe],
      [3, 'CDT',                'cdt.png',               'community_dev',    group_uwe],

      [1, 'Constellation',      'constellation.png',     'constellation',    group_community],
      [2, 'Maptester',          'maptester.png',         'maptester',        group_community],
      [3, 'NS1 Playtester',     'ns1_playtester.png',    nil,                group_community],
      [4, 'PAX 2012',           'pax_2012.png',          nil,                group_community],
      [5, 'Playtester',         'playtester.png',        'playtester',       group_community],

      [1, 'Commander',          'commander.png',         'commander',        group_ingame],

      [1, 'Reinforced Tier 8',  'game_tier_8.png',       'reinforced8',      group_reinforced],
      [2, 'Reinforced Tier 7',  'game_tier_7.png',       'reinforced7',      group_reinforced],
      [3, 'Reinforced Tier 6',  'game_tier_6.png',       'reinforced6',      group_reinforced],
      [4, 'Reinforced Tier 5',  'game_tier_5.png',       'reinforced5',      group_reinforced],
      [5, 'Reinforced Tier 4',  'game_tier_4.png',       'reinforced4',      group_reinforced],
      [6, 'Reinforced Tier 3',  'game_tier_3.png',       'reinforced3',      group_reinforced],
      [7, 'Reinforced Tier 2',  'game_tier_2.png',       'reinforced2',      group_reinforced],
      [8, 'Reinforced Tier 1',  'game_tier_1.png',       'reinforced1',      group_reinforced],

      [1, 'Squad5 Gold',        'squad5_gold.png',       'squad5_gold',      group_squad5],
      [2, 'Squad5 Silver',      'squad5_silver.png',     'squad5_silver',    group_squad5],
      [3, 'Squad5 Blue',        'squad5_blue.png',       'squad5_blue',      group_squad5],

      [1, 'WC 2013 Shadow',     'wc_2013_shadow.png',    'wc2013_shadow',    group_wc2013],
      [2, 'WC 2013 Gold',       'wc_2013_gold.png',      'wc2013_gold',      group_wc2013],
      [3, 'WC 2013 Silver',     'wc_2013_silver.png',    'wc2013_silver',    group_wc2013],
      [4, 'WC 2013 Supporter',  'wc_2013_supporter.png', 'wc2013_supporter', group_wc2013],
    ].each do |ary|
      from(:badges).insert(sort: 1, name: ary[1], image: ary[2], key: ary[3], badge_group_id: ary[4])
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
    drop_table :badge_groups
  end
end
