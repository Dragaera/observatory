Sequel.migration do
  up do
    create_table :update_frequencies do
      primary_key :id

      varchar :name,      null: false, unique: true
      integer :interval,  null: false
      integer :threshold, null: false
      bool    :enabled,   null: false, default: true
      bool    :fallback,  null: false, default: false
    end

    from(:update_frequencies).insert(name: 'Hourly', interval: 60 * 60, threshold: 60 * 60 * 24)
    daily  = from(:update_frequencies).insert(name: 'Daily', interval: 24 * 60 * 60, threshold: 60 * 60 * 24 * 7)
    from(:update_frequencies).insert(name: 'Weekly', interval: 7 * 24 * 60 * 60, threshold: 60 * 60 * 24 * 365, fallback: true)
    from(:update_frequencies).insert(name: 'No Updates', interval: 0, enabled: false, threshold: 0)

    alter_table :players do
      add_foreign_key :update_frequency_id, :update_frequencies, null: false, default: daily
    end
  end

  down do
    alter_table :players do
      drop_foreign_key :update_frequency_id
    end

    drop_table :update_frequencies
  end
end
