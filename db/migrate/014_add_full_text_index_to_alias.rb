Sequel.migration do
  up do
    extension :pg_trgm
    add_pg_trgm :player_data_points, :alias
  end

  down do
    extension :pg_trgm
    drop_pg_trgm :player_data_points, :alias
  end
end
