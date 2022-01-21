FactoryBot.define do
  factory :lot_provenance do
    name { 'Default' }

    trait :state do
      name { 'Provincia' }
    end

    trait :prov_1 do
      name { 'Donación' }
    end

    trait :prov_2 do
      name { 'SSyPR' }
    end

    trait :prov_3 do
      name { 'Muestra médica' }
    end

    trait :prov_4 do
      name { 'Maternidad e infancia' }
    end

    trait :prov_5 do
      name { 'Remediar' }
    end

    factory :province_lot_provenance, traits: [:state]
    factory :provenance_1, traits: [:prov_1]
    factory :provenance_2, traits: [:prov_2]
    factory :provenance_3, traits: [:prov_3]
    factory :provenance_4, traits: [:prov_4]
    factory :provenance_5, traits: [:prov_5]
  end
end
