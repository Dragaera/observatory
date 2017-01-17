FactoryGirl.define do
  to_create(&:save)

  factory :player_query do
    sequence(:query) { |i| "fake-vanity-url-#{ i }" }
    pending true

    trait :successful do
      success true
      pending false
    end

    trait :unsuccessful do
      success false
      pending false
    end
  end

  factory :player do
    sequence(:account_id) { |i| i }
  end

  factory :player_data_point do
    sequence(:alias) { |i| "Player #{ i }" }
    sequence(:hive_player_id) { |i| i }
    score 100
    level 10
    experience 1_000
    skill 500
    time_total 3_600
    time_alien 1_600
    time_marine 2_000
    time_commander 300
    adagrad_sum 0.1
  end
end
