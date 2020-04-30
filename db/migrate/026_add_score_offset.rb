Sequel.migration do
  up do
    alter_table :player_data_points do
      add_column :score_offset,         Integer,   null: false, default: 0
      add_column :score_offset_changed, TrueClass, null: false, default: false
    end

    alter_table :players do
      add_column :score_offset_calculated, TrueClass, null: false, default: false
    end
  end

  down do
    # This is *destructive* in that you lose the incorrect score records. But
    # it is acceptable as you probably do not care about those, and prevents
    # having to restore those in the migration. If desired this can be done by
    # the user manually.o
    # If the migration is done upwards again afterwards, the offset will be
    # recalculated with the next update which yields a way too high value.
    alter_table :player_data_points do
      drop_column :score_offset
      drop_column :score_offset_changed
    end

    alter_table :players do
      drop_column :score_offset_calculated
    end
  end
end
