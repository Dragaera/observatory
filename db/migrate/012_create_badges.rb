Sequel.migration do
  up do
    create_table :badge_groups do
      primary_key :id

      String :name, null: false

      DateTime :created_at
      DateTime :updated_at
    end

    create_table :badges do
      primary_key :id

      foreign_key :badge_group_id, :badge_groups, null: false

      String :name,  null: false
      String :image, null: false
      String :key,   null: true

      DateTime :created_at
      DateTime :updated_at
    end

    group_uwe        = from(:badge_groups).insert(name: 'UWE')
    group_community  = from(:badge_groups).insert(name: 'Community')
    group_wc2013     = from(:badge_groups).insert(name: 'WC 2013')
    group_squad5     = from(:badge_groups).insert(name: 'Squad 5')
    group_ingame     = from(:badge_groups).insert(name: 'Ingame')
    group_reinforced = from(:badge_groups).insert(name: 'Reinforced')
    group_other      = from(:badge_groups).insert(name: 'Other')
    [
      ['CDT',                'cdt.png',               'community_dev',    group_uwe],
      ['Commander',          'commander.png',         'commander',        group_ingame],
      ['Constellation',      'constellation.png',     'constellation',    group_other],
      ['Developer',          'dev.png',               'dev',              group_uwe],
      ['Retired Developer',  'dev_retired.png',        nil,               group_uwe],
      ['Reinforced Tier 1',  'game_tier_1.png',       'reinforced1',      group_reinforced],
      ['Reinforced Tier 2',  'game_tier_2.png',       'reinforced2',      group_reinforced],
      ['Reinforced Tier 3',  'game_tier_3.png',       'reinforced3',      group_reinforced],
      ['Reinforced Tier 4',  'game_tier_4.png',       'reinforced4',      group_reinforced],
      ['Reinforced Tier 5',  'game_tier_5.png',       'reinforced5',      group_reinforced],
      ['Reinforced Tier 6',  'game_tier_6.png',       'reinforced6',      group_reinforced],
      ['Reinforced Tier 7',  'game_tier_7.png',       'reinforced7',      group_reinforced],
      ['Reinforced Tier 8',  'game_tier_8.png',       'reinforced8',      group_reinforced],
      ['Maptester',          'maptester.png',         'maptester',        group_community],
      ['NS1 Playtester',     'ns1_playtester.png',    nil,                group_community],
      ['PAX 2012',           'pax_2012.png',          nil,                group_community],
      ['Playtester',         'playtester.png',        'playtester',       group_community],
      ['Squad5 Blue',        'squad5_blue.png',       'squad5_blue',      group_squad5],
      ['Squad5 Silver',      'squad5_silver.png',     'squad5_silver',    group_squad5],
      ['Squad5 Gold',        'squad5_gold.png',       'squad5_gold',      group_squad5],
      ['WC 2013 Supporter',  'wc_2013_supporter.png', 'wc2013_supporter', group_wc2013],
      ['WC 2013 Silver',     'wc_2013_silver.png',    'wc2013_silver',    group_wc2013],
      ['WC 2013 Gold',       'wc_2013_gold.png',      'wc2013_gold',      group_wc2013],
      ['WC 2013 Shadow',     'wc_2013_shadow.png',    'wc2013_shadow',    group_wc2013],
    ].each do |ary|
      from(:badges).insert(name: ary[0], image: ary[1], key: ary[2], badge_group_id: ary[3])
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
