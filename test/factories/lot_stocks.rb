FactoryBot.define do
  factory :lot_stock do
    quantity { 100 }
    archived_quantity { 0 }
    reserved_quantity { 0 }
    lot
    stock

    trait :a_lot do
      association :lot, factory: :it_lot
    end

    trait :a_stock do
      association :stock, factory: :it_stock
    end

    factory :it_lot_stock, traits: %i[a_lot a_stock]
    # factory :it_lot_stock, traits: %i[a_lot a_stock]
  end
end
