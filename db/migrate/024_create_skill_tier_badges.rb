Sequel.migration do
  up do
    create_table :skill_tier_badges do
      primary_key :id

      String :name,  null: false
      String :image, null: false
      Fixnum :hive_skill_threshold, null: false
      Fixnum :sort,  null: false

      DateTime :created_at
      DateTime :updated_at
    end

    [
      # Special case, applied to anyone below level 20, no matter their skill.
      ['Rookie',         'rookie.png',         -1,   1],
      ['Recruit',        'recruit.png',        0,    2],
      ['Frontiersman',   'frontiersman.png',   551,  3],
      ['Squad Leader',   'squad_leader.png',   1001, 4],
      ['Veteran',        'veteran.png',        1601, 5],
      ['Commandant',     'commandant.png',     2201, 6],
      ['Special Ops',    'special_ops.png',    3001, 7],
      ['Sanji Survivor', 'sanji_survivor.png', 4000, 8],
    ].each do |ary|
      from(:skill_tier_badges).
        insert(
          name:                 ary[0],
          image:                ary[1],
          hive_skill_threshold: ary[2],
          sort:                 ary[3],
          created_at:           Time.now,
        )
    end
  end

  down do
    drop_table :skill_tier_badges
  end
end
