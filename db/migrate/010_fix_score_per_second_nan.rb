Sequel.migration do
  up do
    from(:player_data_points).
      where(score_per_second: Float::NAN).
      update(score_per_second: 0)

    from(:player_data_points).
      where(score_per_second_field: Float::NAN).
      update(score_per_second_field: 0)
  end

  down do
  end
end
