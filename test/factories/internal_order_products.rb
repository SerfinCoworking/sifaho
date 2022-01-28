FactoryBot.define do
  factory :internal_order_product do
    request_quantity { 10 }
    delivery_quantity { 0 }
    provider_observation { 'Provider oberservations test' }
    applicant_observation { 'Some applicant observations test' }

    trait :order_prod_1 do
      association :product, factory: :product_1
    end

    factory :order_product_1, traits: [:order_prod_1]
  end
end