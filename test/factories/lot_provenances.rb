FactoryBot.define do
  factory :lot_provenance do
    name { 'Default' }

    trait :state do
      name { 'Provincia' }
    end

    factory :province_lot_provenance, traits: [:state]
  end
end
