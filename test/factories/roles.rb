FactoryBot.define do
  factory :role do

    trait :role_1 do
      name { 'farmaceutico' }
    end

    factory :role_farmaceutico, traits: %i[role_1]
  end
end
