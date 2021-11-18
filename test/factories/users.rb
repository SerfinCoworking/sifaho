FactoryBot.define do
  factory :user do
    username { 12345678 }
    password { 'password' }
    sector

    trait :current_sector do
      association :sector, factory: :informatica_sector
    end

    factory :info_user, traits: [:current_sector]
  end
end
