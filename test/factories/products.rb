FactoryBot.define do
  factory :product do
    code { "0000" }
    name { "Ibuprofeno 1500mg" }
    description { "Ibuprofeno de 1500mg..." }
    unity
    area

    trait :unidad do
      association :unity, factory: :unidad_unity
    end

    trait :medication do
      association :area, factory: :medication_area
    end

    factory :unidad_product, traits: [:unidad, :medication]
  end
end
