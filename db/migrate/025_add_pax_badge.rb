Sequel.migration do
  up do
    from(:badges).where(name: 'Playtester', type: 'hive').update(sort: 4)
    from(:badges).insert(
      name: 'PAX 2012',
      type: 'hive',
      image: 'pax_2012.png',
      key: 'pax2012',
      sort: 5,
      badge_group_id: from(:badge_groups).first(name: 'Community')[:id]
    )
  end

  down do
    from(:badges).where(name: 'PAX 2012',   type: 'hive').delete
    from(:badges).where(name: 'Playtester', type: 'hive').update(sort: 5)
  end
end
