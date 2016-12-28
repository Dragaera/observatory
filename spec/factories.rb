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
    sequence(:hive2_player_id) { |i| i }
    sequence(:account_id) { |i| i }
  end
end
