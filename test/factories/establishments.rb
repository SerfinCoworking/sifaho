FactoryBot.define do
  factory :establishment do
    name { 'Dr. Juan Hospital' }
    short_name { 'DJH' }
    establishment_type
    sanitary_zone

    trait :hospital_type do
      association :establishment_type, factory: :hospital_establishment_type
    end

    trait :iv_zone do
      association :sanitary_zone, factory: :iv_sanitary_zone
    end

    factory :hospital_establishment, traits: %i[hospital_type iv_zone]
  end
end
