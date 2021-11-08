FactoryBot.define do
  factory :unity do
    name { 'Defuult' }

    trait :aerosol do
      name { 'Aerosol' }
    end

    trait :unidad do
      name { 'Unidad' }
    end

    factory :aerosol_unity, traits: [:aerosol]
    factory :unidad_unity, traits: [:unidad]
  end
end
