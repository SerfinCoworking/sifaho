FactoryBot.define do
  factory :internal_order do
    observation { 'observations' }
    order_type { 'solicitud' }

    trait :ord_1 do
      association :provider_sector, factory: :sector_1
      association :applicant_sector, factory: :sector_4
    end

    factory :order_1, traits: [:ord_1]
  end
end
