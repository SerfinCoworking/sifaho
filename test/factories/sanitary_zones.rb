FactoryBot.define do
  factory :sanitary_zone do
    name { 'Zona Sanitaria IV' }
    state

    trait :state_neuquen do
      association :state, factory: :state
    end

    factory :iv_sanitary_zone, traits: [:state_neuquen]
  end

  factory :state do
    name { 'Neuquén' }
    country

    trait :country_arg do
      association :country, factory: :country
    end
  end

  factory :country do
    name { 'Argentina' }
  end

  factory :establishment_type do
    name { 'Zona sanitaria' }

    trait :depo do
      name { 'Depósito zonal' }
    end

    trait :hospital do
      name { 'Hospital' }
    end

    trait :health_center do
      name { 'Centro de salud' }
    end

    trait :health_center do
      name { 'Centro de salud' }
    end

    factory :hospital_establishment_type, traits: [:hospital]
  end
end
