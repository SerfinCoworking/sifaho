FactoryBot.define do
  factory :stock do
    sector
    product

    trait :it_sector do
      association :sector, factory: :informatica_sector
    end

    trait :a_product do
      association :product, factory: :unidad_product
    end

    factory :it_stock, traits: %i[it_sector a_product]
    factory :it_stock_without_product, traits: %i[it_sector]
  end
end
