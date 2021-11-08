FactoryBot.define do
  factory :area do

    trait :medication  do
      name { 'Medicamentos' }
    end

    factory :medication_area, traits: [:medication]
  end
end
