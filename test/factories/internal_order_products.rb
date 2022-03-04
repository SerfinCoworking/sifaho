FactoryBot.define do
  factory :internal_order_product do
    request_quantity { 10 }
    delivery_quantity { 0 }
    provider_observation { 'Provider oberservations test' }
    applicant_observation { 'Some applicant observations test' }

    trait :order_prod_1 do
      association :product, factory: :product_1
      association :added_by_sector, factory: :sector_4
    end
    
    trait :order_prod_2 do
      association :product, factory: :product_2
      association :added_by_sector, factory: :sector_4
    end

    factory :order_product_1, traits: [:order_prod_1]
    factory :order_product_2, traits: [:order_prod_2]
  end
end