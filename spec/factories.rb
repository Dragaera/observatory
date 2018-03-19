FactoryBot.define do
  to_create(&:save)

  trait :active do
    active true
  end

  trait :inactive do
    active false
  end

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

    trait :with_player_data_points do
      transient do
        count 1
        aliases []
      end

      after(:create) do |player, evaluator|
        evaluator.count.times do
          player.add_player_data_point(build(:player_data_point, alias: evaluator.aliases.shift))
        end
      end
    end
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

  factory :update_frequency do
    fallback false
    enabled  true
  end

  factory :player_data_export do
    player
  end

  factory :user do
    sequence(:user) { |i| "user#{ i }" }
    password 'sekkrit'
  end

  factory :api_key, class: APIKey do
    token SecureRandom.hex(16)
    title 'Test API key'
    description ''
  end
end
