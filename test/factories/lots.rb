FactoryBot.define do
  factory :lot do
    expiry_date { Date.new(2022, 11, 12) }
    code { 'AAA-11' }
    product
    laboratory

    trait :ibuprofeno do
      association :product, factory: :unidad_product
    end

    trait :abbott do
      association :laboratory, factory: :abbott_laboratory
    end

    trait :province do
      association :provenance, factory: :province_lot_provenance
    end

    factory :province_lot, traits: %i[ibuprofeno abbott province]
  end
end
