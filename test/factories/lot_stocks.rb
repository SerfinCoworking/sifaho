FactoryBot.define do
  factory :lot_stock do
    quantity { 100 }
    archived_quantity { 0 }
    reserved_quantity { 0 }
    lot

    trait :lot do
      association :lot, factory: :province_lot
    end

    factory :correct_lot_stock, traits: [:lot]
  end
end
