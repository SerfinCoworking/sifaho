FactoryBot.define do
  factory :lot_archive do
    quantity { 0 }
    observation { '' }
    user
    lot_stock

    trait :a_user do
      association :user, factory: :simple_user
    end

    trait :a_lot_stock do
      association :lot_stock, factory: :it_lot_stock
    end

    factory :a_lot_archive, traits: %i[a_user a_lot_stock]
  end
end
