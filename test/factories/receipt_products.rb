FactoryBot.define do
  factory :receipt_product do
    quantity 2500
    lot_code 'EE-001'
    expiry_date Date.today + 1.year + 2.month
    laboratory

    trait :rp_1 do
      quantity { 3500 }
      lot_code { 'DD-001' }
      expiry_date { Date.today + 1.year }
      association :laboratory, factory: :abbott_laboratory
      association :provenance, factory: :provenance_1
    end

    trait :rp_2 do
      quantity { 500 }
      lot_code { 'zvA-001' }
      expiry_date { Date.today + 6.month }
      association :laboratory, factory: :abbvie_laboratory
      association :provenance, factory: :provenance_2
    end

    trait :rp_3 do
      quantity { 1500 }
      lot_code { 'D0101' }
      expiry_date { Date.today - 1.year }
      association :laboratory, factory: :genomma_laboratory
      association :provenance, factory: :provenance_3
    end

    factory :receipt_product_1, traits: [:rp_1]
    factory :receipt_product_2, traits: [:rp_2]
    factory :receipt_product_3, traits: [:rp_3]
  end
end
